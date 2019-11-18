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

class NeverLateEntryViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    // MARK: Passing/Recieving Data --------------------------------------------------------------------------------
    var addNewEntry: (()->Void)!
    
    var updateEvent: (()->Void)!
    
    var openAppleMaps: (()->Void)?
    

    // MARK: Properties --------------------------------------------------------------------------------
    let buttonColor = #colorLiteral(red: 0.9851665668, green: 0.999414705, blue: 1, alpha: 0.1950181935) //hex: BEB490
    
    let mainBackgroundColor = #colorLiteral(red: 0.9338286519, green: 0.9739060998, blue: 0.9988136888, alpha: 1) //hex: F0F8FE
    
    let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "geometric"))

    func setUpImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
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
    
    let eventTableLabel : UILabel = {
        let label = UILabel()
        label.text = "Upcoming Events:"
        label.textColor = UIColor.gray
        label.adjustsFontSizeToFitWidth = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Table view for displaying the event information
    let eventTable : UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        tableView.backgroundColor = .clear
        tableView.register(EventSummaryCellTableViewCell.self, forCellReuseIdentifier: "eventCell")
        tableView.rowHeight = 90
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: LifeCycle --------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = mainBackgroundColor
        if (traitCollection.userInterfaceStyle == .dark) {
            backgroundImageView.image = #imageLiteral(resourceName: "geometricDarkMode")
        }
        setUpImageView()
        addSubviews()
        updateEvent()
        setUpUI()
        // ask for permission
        AppCoordinator.requestNotificationPermission(requestView: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        openAppleMaps?()
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(neverLateLabel)
        view.addSubview(settingsButton)
        view.addSubview(addButton)
        view.addSubview(eventTableLabel)
        view.addSubview(eventTable)
    }
    
    // sets up the Constraints to all the subviews in the view controller
    func setUpUI() {
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        
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
        
        eventTableLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10).isActive = true
        eventTableLabel.leadingAnchor.constraint(equalTo: eventTable.leadingAnchor).isActive = true
        
        // tableView contraints
        eventTable.topAnchor.constraint(equalTo: eventTableLabel.bottomAnchor).isActive = true
        eventTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width/50).isActive = true
        eventTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        eventTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/50).isActive = true
        eventTable.delegate = self
        eventTable.dataSource = self
    }
    
    // MARK: Actions  --------------------------------------------------------------------------------
    @objc func onSettingsButton() {
        print("Moving to the settings view")
    }
    // Presents the addNewViewController where the user can add new events
    @objc func onAddButton() {
        // callback defined by the AppCoordinator
        addNewEntry()
    }
    
    var events: [Event] = [Event]()
}

// MARK: google request UI response --------------------------------------------------------------------------------

extension NeverLateEntryViewController {
    @objc func reloadTableData() {
        DispatchQueue.main.async {
            self.updateEvent()
            self.eventTable.reloadData()
            self.removeNotificationObservers()
        }
    }
    
    @objc func openMapsFromNotification() {
        openAppleMaps?()
    }
    
    @objc func invalidRequestPresentError() {
        let invalidRequestAlert = UIAlertController(title: "There is not enough time to reach your destination", message: "", preferredStyle: .alert)
        invalidRequestAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
        self.present(invalidRequestAlert, animated: true)
        removeNotificationObservers()
    }
    
    @objc func networkErrorPresentError() {
        let invalidRequestAlert = UIAlertController(title: "There has been a network error", message: "", preferredStyle: .alert)
        invalidRequestAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
        self.present(invalidRequestAlert, animated: true)
        removeNotificationObservers()
    }
    
    func addNotificationObservers() {
        let reloadEvents = Notification.Name(rawValue: "reloadEvents")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: reloadEvents, object: nil)
        
        let invalidRequest = Notification.Name(rawValue: "invalidRequest")
        NotificationCenter.default.addObserver(self, selector: #selector(invalidRequestPresentError), name: invalidRequest, object: nil)
        
        let networkError = Notification.Name(rawValue: "networkError")
        NotificationCenter.default.addObserver(self, selector: #selector(networkErrorPresentError), name: networkError, object: nil)
    }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reloadEvents"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("invalidRequest"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("networkError"), object: nil)
    }
}




// MARK: TableView Functionality --------------------------------------------------------------------------------
extension NeverLateEntryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventSummaryCellTableViewCell
        cell.set(passedEvent: events[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    // Gives ability to edit the event table
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppCoordinator.openAppleMaps(event: events[indexPath.row])
    }
    
    // Handling deleting Events and cooresponding notifications
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            AppCoordinator.deleteEvent(event: events[indexPath.row])
            AppCoordinator.removeEventNotifications(event: events[indexPath.row])
            events.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
