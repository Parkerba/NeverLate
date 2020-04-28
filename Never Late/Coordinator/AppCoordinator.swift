import UIKit
import UserNotifications
import MapKit


// MARK: Singleton notification helper to AppCoordinator, needed for delegation
private class NotificationComponent: NSObject, UNUserNotificationCenterDelegate {
    private override init() {
        super.init()
    }
    //Singleton object
    static let notificationCoordinator = NotificationComponent()
    
    //User clicked on notification option
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "openWithMaps" {
            let event = EventManager.load(response.notification.request.identifier, with: Event.self)
            DispatchQueue.main.async {
                AppCoordinator.openAppleMaps(event: event)
            }
        }
        completionHandler()
    }
}

// MARK: - AppCoordinator - Handles the program flow and data passing.
final class AppCoordinator: NSObject, EventReciever {
    
    func getDriveTimeInformation(_ event: Event) {
        let url = GoogleRequest.getDriveTimeUrl(event: event)
        GoogleRequest.performRequest(url: url, event: event)
        rootViewController.addNotificationObservers()
    }
    
    func createEvent(event: Event) {
        AppCoordinator.saveEvent(event: event)
        reloadEvents()
        
        if (event.locationName == nil) {
            AppCoordinator.addNotification(event: event)
        }
            
        else {
            getDriveTimeInformation(event)
        }
    }
    
    func reloadEvents() {
        rootViewController.events = EventManager.loadAll(type: Event.self).sorted(by: { $0.eventDate < $1.eventDate})
        rootViewController.eventTable.reloadData()
    }
    
    // MARK: Enum
    enum AppError: LocalizedError {
        case custom(String)
        
        var errorDescription: String? {
            switch self {
            case .custom(let message):
                return message
            }
        }
    }
    
    // MARK: Properties
    private(set) var rootViewController: NeverLateEntryViewController
    private var navController: UINavigationController
    
    // MARK: Life Cycle --------------------------------------------------------------------------------
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController.viewControllers.first as! NeverLateEntryViewController
        self.navController = rootViewController
    }
    
    func displayAddNewViewController() {
        let vc = AddNewViewController()
        vc.displayMap = {
            self.displayMapView(addNewVC: vc)
        }
        vc.delegate = self
        navController.pushViewController(vc, animated: true)
    }
    
    func displayMapView(addNewVC: AddNewViewController) {
        let vc = MapView()
        vc.sendEvent = { destinationLocation, startingLocation in
            addNewVC.destinationLocation = destinationLocation
            addNewVC.addLocationButton.setTitle(destinationLocation.name, for: .normal)
            addNewVC.startingLocation = startingLocation
        }
        navController.pushViewController(vc, animated: true)
    }
    
    func start() {
        rootViewController.addNewEntry = {
            self.displayAddNewViewController()
        }
        
        rootViewController.refreshEvent = { event in
            self.getDriveTimeInformation(event)
        }
        rootViewController.updateEventTable = {
            self.reloadEvents()
        }
    }
    
    // MARK: Notification logic --------------------------------------------------------------------------------
    static func requestNotificationPermission(requestView: UIViewController) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert,.sound], completionHandler: { granted, error in
            if let error = error {
                print (error.localizedDescription)
            }
            if (!granted) {
                let alert = UIAlertController(title: "Notification Permission Denied", message: "Please provide permission in settings for an optimal experience.", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
                alert.addAction(dismissAction)
                requestView.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // This will schedule a notification for the time of the event
    #warning("Check for location when creating notification action/abstract further")
    static public func addNotification(event: Event) {
        UNUserNotificationCenter.current().delegate = NotificationComponent.notificationCoordinator
        
        
        
        // Setting up the content of the notification
        let content = getNotificationContent(event: event)
        
        let openWithMapsAction = UNNotificationAction(identifier: "openWithMaps", title: "Open in Maps", options: [.foreground])
        
        let category = UNNotificationCategory(identifier: "notificationAction", actions: [openWithMapsAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
        let mainDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: event.departureTime ?? event.eventDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: mainDate, repeats: false)
        
        let mainRequest = UNNotificationRequest(identifier: event.eventIdentifier.uuidString, content: content.mainNotificationContent, trigger: trigger)
        
        if let offsetContent = content.offSetNotificationContent {
            // submit Notification for offset notification
            let offsetInSeconds = event.offset*60
            let offsetDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: (event.departureTime ?? event.eventDate) - Double(offsetInSeconds))
            
            let offsetNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: offsetDate, repeats: false)
            
            let offsetRequest = UNNotificationRequest(identifier: "\(event.eventIdentifier.uuidString)\(event.offset)", content: offsetContent, trigger: offsetNotificationTrigger)
            
            UNUserNotificationCenter.current().add(offsetRequest) { error in
                if let error = error {
                    print ("Failed to add notification: \(error.localizedDescription)")
                }
            }
        }
        
        UNUserNotificationCenter.current().add(mainRequest) { error in
            if let error = error {
                print ("Failed to add notification: \(error.localizedDescription)")
            }
        }
    }
    
    static private func getNotificationContent(event: Event) -> EventNotificationContent {
        var offSetNotificationContent: UNMutableNotificationContent? = nil
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = event.title
        notificationContent.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1)
        if let locationName = event.locationName {
            notificationContent.body = " \(event.title): You need to leave for \(locationName)."
            
        } else {
           notificationContent.body = " \(event.title)"
        }
        
        if (event.offset != 0) { // Offset exists two notifications will be made
            offSetNotificationContent = UNMutableNotificationContent()
            offSetNotificationContent?.title = event.title
            offSetNotificationContent?.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1)
            if let locationName = event.locationName {
                offSetNotificationContent?.body = " \(event.title): You need to leave for \(locationName) in \(event.offset) minutes."
                
            } else {
                offSetNotificationContent?.body = " \(event.title): \(event.offset) minutes."
            }
        }
        
        return EventNotificationContent(offSetNotificationContent: offSetNotificationContent, mainNotificationContent: notificationContent)
    }
    
    
    
    static func deleteEvent(event: Event) {
        EventManager.delete(event.eventIdentifier.uuidString)
    }
    
    static func saveEvent(event: Event) {
        EventManager.save(object: event.self, with: event.eventIdentifier.uuidString)
    }
    
    static func updateEvent(event: Event) {
        saveEvent(event: event)
        removeEventNotifications(event: event)
        addNotification(event: event)
    }
    
    static func removeEventNotifications(event: Event) {
        let identifiers : [String] = [event.eventIdentifier.uuidString, "\(event.eventIdentifier.uuidString)\(event.offset)"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    static func openAppleMaps(event: Event) {
        guard let lat = event.locationLatitude else {
            return
        }
        
        guard let long = event.locationLongitude else {
            return
        }
        
        guard let name = event.locationName else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [:])
    }
}

