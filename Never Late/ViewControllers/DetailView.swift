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
    
    var parentRef: NeverLateEntryViewController?
    
    var dismissAnimation : (() -> Void)!
    
    let titleText : UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "Copperplate-Bold", size: 20)!
        field.placeholder = "Title"
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
       
       //Line separating the views
    let dividerView : UIView = {
        let retView = UIView()
        retView.backgroundColor = .lightGray
        
        retView.translatesAutoresizingMaskIntoConstraints = false
        return retView
    }()
       
       //Line separating the views
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
           
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
        
    var dismissButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(#imageLiteral(resourceName: "downArrow"), for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return button
    }()
    
    var dismissBackground : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
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
        addSubview(dismissBackground)
        addSubview(dismissButton)
    }
    
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
        
    func setUp(event: Event) {
        customizeAppearance()
        addSubviews()
        setTextFields(event)
        setConstraints()
        self.event = event
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
    
    @objc func refresh() {
        let userRefreshPreference = UIAlertController(title: "Refresh", message: "Would you like to update the starting location to your current location or use the previously set starting location?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Current", style: .default) { _ in
            let locationManager = CLLocationManager()
            let currentLocation = locationManager.location?.coordinate
            self.event.currentLatitude = currentLocation?.latitude
            self.event.currentLongitude = currentLocation?.longitude
            self.parentRef?.refreshEvent?(self.event)
        }
        
        let no = UIAlertAction(title: "Original", style: .default) { _ in
            self.parentRef?.refreshEvent?(self.event)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        userRefreshPreference.addAction(yes)
        userRefreshPreference.addAction(no)
        userRefreshPreference.addAction(cancel)
        parentRef?.present(userRefreshPreference, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

