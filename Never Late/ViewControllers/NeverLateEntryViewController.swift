//
//  NeverLateEntryViewController.swift
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
    
    var updateEventTable: (()->Void)!
    
    var openAppleMaps: (()->Void)!
    
    var refreshEvent: ((Event)->Void)!
    
    var events = [Event]()
    
    weak var detailViewReference : DetailView?
    
    // MARK: Properties --------------------------------------------------------------------------------
        
    // Top label denoting the name of the app
    let neverLateLabel : UILabel = {
        let label : UILabel = UILabel()
        label.text = "NeverLate"
        let labelFont: UIFont = UIFont(name: "Copperplate-Bold", size: 30)!
        label.font = labelFont
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        tableView.register(EventSummaryCellTableViewCell.self, forCellReuseIdentifier: Constants.entryVCCellIdentifier)
        tableView.rowHeight = 90
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let detailViewBlurr : UIView = {
        let blurrView = UIView()
        blurrView.layer.opacity = 0.4
        blurrView.backgroundColor = .lightGray
        blurrView.isHidden = true
        
        blurrView.translatesAutoresizingMaskIntoConstraints = false
        return blurrView
    }()
    
    // MARK: LifeCycle --------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backGroundColor
        addSubviews()
        updateEventTable()
        setUpUI()
        // ask for permission
        AppCoordinator.requestNotificationPermission(requestView: self)
    }
    
    
    private func addSubviews() {
        view.addSubview(neverLateLabel)
        view.addSubview(addButton)
        view.addSubview(eventTableLabel)
        view.addSubview(eventTable)
        view.addSubview(detailViewBlurr)
    }
    
    // sets up the Constraints to all the subviews in the view controller
    private func addConstraints() {
        // app name label constraints
        neverLateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        neverLateLabel.heightAnchor.constraint(equalToConstant: view.frame.height/7).isActive = true
        neverLateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // add button constraints
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height*0.70).isActive = true
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width/10).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/10).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: view.frame.height/7).isActive = true
        addButton.backgroundColor = Constants.accentColor
        
        eventTableLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10).isActive = true
        eventTableLabel.leadingAnchor.constraint(equalTo: eventTable.leadingAnchor).isActive = true
        
        // tableView contraints
        eventTable.topAnchor.constraint(equalTo: eventTableLabel.bottomAnchor).isActive = true
        eventTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width/50).isActive = true
        eventTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        eventTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width/50).isActive = true
        
        detailViewBlurr.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        detailViewBlurr.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        detailViewBlurr.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailViewBlurr.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailViewBlurr.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func setDelegates() {
        eventTable.delegate = self
        eventTable.dataSource = self
    }
    
    private func setUpUI() {
        addConstraints()
        setDelegates()
    }
    
    // MARK: Actions  --------------------------------------------------------------------------------
    // Presents the addNewViewController where the user can add new events
    @objc func onAddButton() {
        // callback defined by the AppCoordinator
        addNewEntry()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: google request UI response --------------------------------------------------------------------------------

extension NeverLateEntryViewController {
    @objc func reloadTableData() {
        DispatchQueue.main.async {
            self.updateEventTable()
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
        let reloadevents = Notification.Name(rawValue: Constants.reloadEventsNotificationIdenifier)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: reloadevents, object: nil)
        
        let invalidRequest = Notification.Name(rawValue: Constants.invalidRequestNotificationIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(invalidRequestPresentError), name: invalidRequest, object: nil)
        
        let networkError = Notification.Name(rawValue: Constants.networkErrorNotificationIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(networkErrorPresentError), name: networkError, object: nil)
    }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.reloadEventsNotificationIdenifier), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.invalidRequestNotificationIdentifier), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(Constants.networkErrorNotificationIdentifier), object: nil)
    }
}

// MARK: TableView/DetailView Functionality --------------------------------------------------------------------------------
extension NeverLateEntryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.entryVCCellIdentifier, for: indexPath) as! EventSummaryCellTableViewCell
        cell.set(passedEvent: events[indexPath.row])
        cell.selectionStyle = .blue
        return cell
    }
    
    // Gives ability to edit the event table
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Display the Detail view with animation
    // Define DetailView with event information, Define DetailView's dismiss animation.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // blur background
        detailViewBlurr.isHidden = false
        
        // remove previous DetailView if present to avoid excess memory usage
        if let dv = detailViewReference {
            dv.removeFromSuperview()
        }
        
        let dv = DetailView()
        dv.translatesAutoresizingMaskIntoConstraints = false
        dv.setUp(event: events[indexPath.row])
        dv.parentRef = self
        view.addSubview(dv)
        displayAndDefineDetailViewDismissAnimation(dv)
    }
    
    
    // This provides swipe left to delete functionality for each of the event cells
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [unowned self] _,_,_ in
            AppCoordinator.deleteEvent(event: self.events[indexPath.row])
            AppCoordinator.removeEventNotifications(event: self.events[indexPath.row])
            self.events.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // This provides swipe right to open in maps functionality for each of the event cells
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let openMapsAction = UIContextualAction(style: .normal, title: "Open in Maps") { [unowned self] _,_,_  in
            AppCoordinator.openAppleMaps(event: self.events[indexPath.row])
        }
        
        openMapsAction.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [openMapsAction])
    }
    
    
    // Displays already instantiated DetailView by animating change of y constraint
    // this method is called when a user taps on an event cell
    private func displayAndDefineDetailViewDismissAnimation(_ dv: DetailView) {
        // Move to just above user's view
        var yAnchor = dv.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -20)
        yAnchor.isActive = true
        dv.widthAnchor.constraint(equalToConstant: view.frame.width/1.5).isActive = true
        dv.heightAnchor.constraint(equalToConstant: view.frame.height/2).isActive = true
        dv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.layoutIfNeeded()
        
        // Move to the middle of the user's view (animated)
        yAnchor.isActive = false
        yAnchor = dv.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        yAnchor.isActive = true
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
        // Define DetailView's DismissAnimation
        dv.dismissAnimation = { [unowned self] in
            yAnchor.isActive = false
            yAnchor = dv.topAnchor.constraint(equalTo: (self.view.bottomAnchor))
            yAnchor.isActive = true
            UIView.animate(withDuration: 0.4, animations: { self.view.layoutIfNeeded()}) { (finished: Bool) in
                self.updateEventTable()
                self.detailViewBlurr.isHidden = true
            }
        }
    }
}
