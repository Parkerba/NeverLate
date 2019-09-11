//
//  AddNewViewController.swift
//  Never Late
//
//  Created by parker amundsen on 7/17/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import UIKit
import MapKit
protocol EventReciever {
    func recieveEvent(event: Event)
}
class AddNewViewController: UIViewController, UITextFieldDelegate, locationReciever {
    func recieveEventLocation(placemark: MKPlacemark?) {
        self.location = placemark
        if let local = placemark {
            self.addLocationButton.setTitle(local.name, for: .normal)
        }
    }
    
    var delegate: EventReciever?
    
    var location: MKPlacemark?
    
    // colors used
    let mainBackgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9725490196, blue: 0.9960784314, alpha: 1)
    let buttonColor = #colorLiteral(red: 0.6823529412, green: 0.7960784314, blue: 0.8705882353, alpha: 1)
    
    // UILabel at the top of the view
    let neverLateLabel : UILabel = {
        let label : UILabel = UILabel()
        label.text = "NeverLate"
        let labelFont: UIFont = UIFont(name: "Copperplate-Bold", size: 30)!
        label.font = labelFont
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let eventTitleTextField : UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.font = UIFont(name: "Copperplate-Bold", size: 20)!
        
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
    
    let eventDescriptionTextField : UITextField = {
        let field = UITextField()
        field.placeholder = "Description"
        field.font = UIFont(name: "Copperplate-Bold", size: 20)!
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let addLocationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Location", for: .normal)
        button.addTarget(self, action: #selector(onSetLocationButton) , for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "Copperplate-Bold", size: 25)!
        button.titleLabel?.numberOfLines = 0
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let datePicker : UIDatePicker = {
        let datePickerView = UIDatePicker()
        datePickerView.minimumDate = Date()
        datePickerView.backgroundColor = .clear
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        return datePickerView
    }()
    
    let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont(name: "Copperplate-Bold", size: 25)!
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(onDoneButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let isRepeating: UISwitch = {
        let repeatingSwitch = UISwitch()
        repeatingSwitch.isOn = false
        repeatingSwitch.translatesAutoresizingMaskIntoConstraints = false
    
        return repeatingSwitch
    }()
    
    let isRepeatingLabel: UILabel = {
        let label = UILabel()
        label.text = "Repeating"
        label.font = UIFont(name: "Copperplate-Bold", size: 15)!
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = mainBackgroundColor
        view.addSubview(containerView)
        view.addSubview(doneButton)
        view.addSubview(datePicker)
        view.addSubview(isRepeating)
        view.addSubview(isRepeatingLabel)
        view.addSubview(neverLateLabel)
        view.addSubview(dividerView)
        view.addSubview(secondDividerView)
        view.addSubview(eventTitleTextField)
        view.addSubview(eventDescriptionTextField)
        view.addSubview(addLocationButton)
        setUpUI()
        self.eventTitleTextField.delegate = self
        self.eventDescriptionTextField.delegate = self
    }
    
    // Sends the new event to the entryPoint
    @objc func onDoneButton() {
        delegate?.recieveEvent(event: Event(datePicked: datePicker.date, eventName: eventTitleTextField.text ?? "", eventLocation: location, EventDescription :eventDescriptionTextField.text ?? "" ))
        self.dismiss(animated: true, completion: nil)
    }
    
    // Dismisses the addNewEventViewController without creating a view
    @objc func onSwipeBack() {
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: nil)
    }
    
    // sets up the Constraints to all the subviews in the view controller
    private func setUpUI() {
        
        neverLateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        neverLateLabel.heightAnchor.constraint(equalToConstant: view.frame.height/7).isActive = true
        neverLateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        eventTitleTextField.centerYAnchor.constraint(equalTo: neverLateLabel.bottomAnchor, constant: 10).isActive = true
        eventTitleTextField.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor).isActive = true
        eventTitleTextField.widthAnchor.constraint(equalToConstant: datePicker.frame.width).isActive = true
        
        dividerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.centerYAnchor.constraint(equalTo: eventTitleTextField.bottomAnchor, constant: 5).isActive = true
        dividerView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        secondDividerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        secondDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        secondDividerView.centerYAnchor.constraint(equalTo: eventDescriptionTextField.bottomAnchor, constant: 5).isActive = true
        secondDividerView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        addLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addLocationButton.topAnchor.constraint(equalTo: secondDividerView.bottomAnchor, constant: 10).isActive = true
        addLocationButton.backgroundColor = buttonColor
        addLocationButton.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width*0.8).isActive = true
        
        eventDescriptionTextField.topAnchor.constraint(equalTo: eventTitleTextField.bottomAnchor, constant: 10).isActive = true
        eventDescriptionTextField.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor).isActive = true
        eventDescriptionTextField.widthAnchor.constraint(equalToConstant: datePicker.frame.width).isActive = true

        
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.height/20).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: view.frame.width*0.8).isActive = true
        doneButton.backgroundColor = buttonColor
        
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        isRepeatingLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10).isActive = true
        isRepeatingLabel.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor).isActive = true
        isRepeating.topAnchor.constraint(equalTo: isRepeatingLabel.bottomAnchor).isActive = true
        isRepeating.leadingAnchor.constraint(equalTo: isRepeatingLabel.leadingAnchor).isActive = true
        
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .right
        gesture.addTarget(self, action: #selector(onSwipeBack))
        gesture.isEnabled = true
        containerView.addGestureRecognizer(gesture)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func onSetLocationButton() {
        let vc = MapView()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}
