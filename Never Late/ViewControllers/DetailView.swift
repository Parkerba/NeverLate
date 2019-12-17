//
//  DetailView.swift
//  Never Late
//
//  Created by parker amundsen on 11/23/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class DetailView: UIView, UITextFieldDelegate {
    
    var event: Event!
    
    weak var parentRef: NeverLateEntryViewController?
    
    var dismissAnimation : (() -> Void)!
    
    let titleText : UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "Copperplate-Bold", size: 20)!
        field.placeholder = "Title"
        field.adjustsFontSizeToFitWidth = true
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
       
       //Line separating the textfield
    let dividerView : UIView = {
        let retView = UIView()
        retView.backgroundColor = .lightGray
        
        retView.translatesAutoresizingMaskIntoConstraints = false
        return retView
    }()
       
       //Line separating the textfield
    let secondDividerView : UIView = {
        let retView = UIView()
        retView.backgroundColor = .lightGray
        
        retView.translatesAutoresizingMaskIntoConstraints = false
        return retView
    }()
       
    let descriptionText : UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "Copperplate-Bold", size: 20)!
        field.placeholder = "Description"
        field.adjustsFontSizeToFitWidth = true
           
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let driveTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Copperplate-Bold", size: 15)!
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let arrivalTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Copperplate-Bold", size: 15)!
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let departureTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Copperplate-Bold", size: 15)!
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    var dismissButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "downArrow"), for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(dismiss), for: .allTouchEvents)
        return button
    }()
    
    var dismissBackground : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var refreshButton : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "refreshIcon"), for: .normal)
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
      }()
    
    var saveButton : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "saveIcon"), for: .normal)
        button.addTarget(self, action: #selector(saveUpdate), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    fileprivate func customizeAppearance() {
        layer.cornerRadius = 10
        clipsToBounds = true
        self.backgroundColor = .white
    }
    
    fileprivate func addSubviews() {
        addSubview(titleText)
        addSubview(refreshButton)
        addSubview(saveButton)
        addSubview(dividerView)
        addSubview(secondDividerView)
        addSubview(descriptionText)
        addSubview(arrivalTimeLabel)
        addSubview(departureTimeLabel)
        addSubview(driveTimeLabel)
        addSubview(dismissBackground)
        addSubview(dismissButton)
    }
    
    // formats the textfields
    fileprivate func setTextFields(_ event: Event) {
        titleText.text = event.title
        titleText.font = UIFont(name: "Copperplate-Bold", size: 20)!
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.delegate = self
        
        descriptionText.text = event.eventDescription
        descriptionText.font = UIFont(name: "Copperplate-Bold", size: 20)!
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.delegate = self
    }
    
    // Sets the constraints of properties
    fileprivate func setConstraints() {
        
        titleText.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10).isActive = true
        titleText.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        titleText.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        dividerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.centerYAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5).isActive = true
        dividerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        descriptionText.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 5).isActive = true
        descriptionText.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        descriptionText.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        secondDividerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        secondDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        secondDividerView.centerYAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 5).isActive = true
        secondDividerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        driveTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        driveTimeLabel.topAnchor.constraint(equalTo: secondDividerView.bottomAnchor, constant: 5).isActive = true
        
        departureTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        departureTimeLabel.topAnchor.constraint(equalTo: driveTimeLabel.bottomAnchor, constant: 5).isActive = true

        arrivalTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        arrivalTimeLabel.topAnchor.constraint(equalTo: departureTimeLabel.bottomAnchor, constant: 5).isActive = true

        refreshButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -5).isActive = true
        
        dismissButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        dismissBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        dismissBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        dismissBackground.topAnchor.constraint(equalTo: dismissButton.topAnchor).isActive = true
        dismissBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
    
    // Sets the constraints, text and gesture recognizers of the properties.
    func setUp(event: Event) {
        customizeAppearance()
        addSubviews()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss))
        swipeDownGesture.direction = .down
        self.addGestureRecognizer(swipeDownGesture)
        dismissBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        setTextFields(event)
        setConstraints()
        self.event = event
        setLabels()
    }
    
    @objc func dismiss() {
        dismissAnimation()
    }
    
    @objc func saveUpdate() {
        event.title = titleText.text ?? ""
        event.eventDescription = descriptionText.text ?? ""
        AppCoordinator.updateEvent(event: event)
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    // This gives the user the option to refresh the drive time information by presenting an alert view controller
    @objc func refresh() {
        
        
        let userRefreshPreference = UIAlertController(title: "Refresh", message: "Would you like to update the starting location to your current location or use the previously set starting location?", preferredStyle: .alert)
        
        // Grabs users current location and uses this as the starting location.
        let yes = UIAlertAction(title: "Current", style: .default) { _ in
            let locationManager = CLLocationManager()
            let currentLocation = locationManager.location?.coordinate
            self.event.currentLatitude = currentLocation?.latitude
            self.event.currentLongitude = currentLocation?.longitude
            self.parentRef?.refreshEvent?(self.event)
            self.dismiss()
        }
        // Refreshes using the currently set starting location of the event.
        let no = UIAlertAction(title: "Original", style: .default) { _ in
            self.parentRef?.refreshEvent?(self.event)
            self.dismiss()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        userRefreshPreference.addAction(yes)
        userRefreshPreference.addAction(no)
        userRefreshPreference.addAction(cancel)
        parentRef?.present(userRefreshPreference, animated: true, completion: nil)
    }
    
    // Sets the text of the labels
    func setLabels() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = .autoupdatingCurrent
        departureTimeLabel.text = "Departure Time: \(formatter.string(from: event.departureTime!))"
        arrivalTimeLabel.text = "Arrival Time: \(formatter.string(from: event.eventDate))"
        driveTimeLabel.text = "Drive time: \(String(event.driveTime!/60)) min"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

