//
//  ViewController.swift
//  Never Late
//
//  Created by parker amundsen on 7/17/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class NeverLateEntryViewController: UIViewController {
    
    var addNewEntry: (()->Void)?
    
    let buttonColor = #colorLiteral(red: 0.6823529412, green: 0.7960784314, blue: 0.8705882353, alpha: 0.6009203767) //hex: AECBDE
    let mainBackgroundColor = #colorLiteral(red: 0.9338286519, green: 0.9739060998, blue: 0.9988136888, alpha: 1) //hex: F0F8FE
    
    // Top label denoting the name of the app
    let neverLateLabel : UILabel = {
        let label : UILabel = UILabel()
        label.text = "NeverLate"
        let labelFont: UIFont = UIFont(name: "Copperplate-Bold", size: 30)!
        label.font = labelFont
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // settings button
    let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "settingsIcon"),for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(onSettingsButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // button to present the VC to create new events
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "addIcon"),for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(onAddButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Table view for displaying the event information
    let cellID = "eventCell"
    let eventTable : UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        tableView.layer.cornerRadius = 15
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = mainBackgroundColor
        view.addSubview(neverLateLabel)
        view.addSubview(settingsButton)
        view.addSubview(addButton)
        view.addSubview(eventTable)
        self.loadEvents()
        setUpUI()
        
        // ask for permission
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert,.sound], completionHandler: {(granted, error) in
            
            }
        )
        
        // create notification content
//        let content = UNMutableNotificationContent()
//        content.title = "Time to Leave for EVENT NAME"
//        content.body = "You need to be at LOCATION NAME by EVENT TIME"
//
//        // create notification trigger
//        let currentDate = Date()
//
//        let dateComponents = Calendar.current.dateComponents([.year,.month, .hour, .minute, .second], from: currentDate)
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//
//        // create the request
//        let uuidString = UUID().uuidString
//        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
//
//        // register with notification center
//        notificationCenter.add(request) { (error) in
//
//        }
        // Do any additional setup after loading the view.
    }
    
    
    func setUpRequest(event: Event) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Leave for \(event.title)"
        content.body = "You need to be at \(event.locationName)"
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .hour, .minute, .second], from: event.eventDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.eventIdentifier.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            
        }
    }
    
    // sets up the Constraints to all the subviews in the view controller
    func setUpUI() {
        
        // app name label constraints
        neverLateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        neverLateLabel.heightAnchor.constraint(equalToConstant: view.frame.height/7).isActive = true
        neverLateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // settings button contraints
        settingsButton.topAnchor.constraint(equalTo: neverLateLabel.bottomAnchor, constant: 10).isActive = true
        settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width/10).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/10).isActive = true
        settingsButton.backgroundColor = buttonColor
        
        // add button constraints
        addButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 10).isActive = true
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width/10).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/10).isActive = true
        addButton.heightAnchor.constraint(equalTo: settingsButton.heightAnchor).isActive = true
        addButton.backgroundColor = buttonColor
        
        // tableView contraints
        eventTable.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 20).isActive = true
        eventTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width/50).isActive = true
        eventTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        eventTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/50).isActive = true
        eventTable.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        eventTable.delegate = self
        eventTable.dataSource = self
    }
    
    
    
    
    
    @objc func onSettingsButton() {
        print("Moving to the settings view")
    }
    // Presents the addNewViewController where the user can add new events
    @objc func onAddButton() {
        addNewEntry?()
    }
    
    var events: [Event] = [Event]()
    
    func loadEvents() {
        events = EventManager.loadAll(type: Event.self)
        events.sort(by: { $0.eventDate < $1.eventDate})
    }
    
    // recieves the event sent from the addNewViewController
    func addEvent(event: Event) {
        event.saveEvent()
        events.append(event)
        events.sort(by: { $0.eventDate < $1.eventDate})
        setUpRequest(event: event)
    }

}

extension NeverLateEntryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var eventLocation: String = ""
        if (events[indexPath.row].locationName != nil) {
            eventLocation = "Location: \(events[indexPath.row].locationName!)\n"
        }
        let eventName: String = "\(events[indexPath.row].title) \n"
        cell.textLabel?.text = "\(eventName)\(eventLocation)\(events[indexPath.row].currentTime())"
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .clear
        return cell
    }
    
    // Modfiying the ability to edit the event table
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Handling deleting Events
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            events[indexPath.row].deleteEvent()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [events[indexPath.row].eventIdentifier.uuidString])
            self.events.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        
    }
    

}


