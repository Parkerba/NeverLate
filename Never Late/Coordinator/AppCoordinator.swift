import UIKit
import UserNotifications
import MapKit


// MARK: Singleton notification helper to AppCoordinator, needed for delegation
fileprivate class NotificationComponent: NSObject, UNUserNotificationCenterDelegate {
    private override init() {
        super.init()
    }
    static let notificationCoordinator = NotificationComponent()
    
    
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
    
    func recieveEvent(event: Event) {
        rootViewController.addEvent(event: event)
        rootViewController.dismiss(animated: true, completion: nil)
        rootViewController.eventTable.reloadData()
    }
    
    func reloadEvents() {
        rootViewController.loadEvents()
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
    
    // MARK: Life Cycle
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
    }
    

    // MARK: Notification logic
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
        var reminderName = ""
        if (event.locationName != nil) {
            reminderName = ", you need to be at \(event.locationName!)"
        }
          
        // Setting up the content of the notification
        let content = UNMutableNotificationContent()
        content.body = "\(event.title)\nTime to leave\(reminderName)"
        content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 1)
        content.categoryIdentifier = "notificationAction"
        
          
        let openWithMapsAction = UNNotificationAction(identifier: "openWithMaps", title: "Open in Maps", options: [.foreground])
        let category = UNNotificationCategory(identifier: "notificationAction", actions: [openWithMapsAction], intentIdentifiers: [], options: [])
          
        UNUserNotificationCenter.current().setNotificationCategories([category])
          
          
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: event.departureTime ?? event.eventDate)
          
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
          
        let request = UNNotificationRequest(identifier: event.eventIdentifier.uuidString, content: content, trigger: trigger)
          
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print ("Failed to add notification: \(error.localizedDescription)")
            }
        }
    }
    
    static func removeEventNotifications(event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.eventIdentifier.uuidString])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [event.eventIdentifier.uuidString])
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

