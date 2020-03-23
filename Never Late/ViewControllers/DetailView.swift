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
import MapKit
import AudioToolbox

// This is a custom view to show the information related to an
// event to the user. This also allows the user to edit the
// event and update relevant stored information and scheduled
// notifications.
class DetailView: UIView, UITextFieldDelegate {
    
    // MARK: Properties --------------------------------------------------------------------------------
    
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
    
    var routeMap : MKMapView  = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 3
        map.showsUserLocation = true
        map.isUserInteractionEnabled = false
        return map
    }()
    
    private func customizeAppearance() {
        layer.cornerRadius = 10
        clipsToBounds = true
        self.backgroundColor = .white
    }
    
    // MARK: Lifecycle --------------------------------------------------------------------------------
    
    private func addSubviews() {
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
        addSubview(routeMap)
    }
    
    // formats the textfields
    private func setTextFields(_ event: Event) {
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
    private func setConstraints() {
        
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
        
        routeMap.bottomAnchor.constraint(equalTo: self.dismissButton.topAnchor, constant: -5).isActive = true
        routeMap.topAnchor.constraint(equalTo: self.arrivalTimeLabel.bottomAnchor, constant: 5).isActive = true
        routeMap.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        routeMap.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        
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
        routeMap.delegate = self
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(openMaps)))
        showMaproute()
    }
    
    
    // Sets the text of the labels
    func setLabels() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = .autoupdatingCurrent
        if let departureTime = event.departureTime {
            departureTimeLabel.text = "Departure Time: \(formatter.string(from: departureTime))"
            driveTimeLabel.text = "Drive time: \(String(event.driveTime!/60)) min"
        } else {
            departureTimeLabel.text = "Departure Time: N/A"
            driveTimeLabel.text = "Drive time: N/A"
        }
        arrivalTimeLabel.text = "Arrival Time: \(formatter.string(from: event.eventDate))"
    }
    // MARK: Actions --------------------------------------------------------------------------------
    
    @objc func dismiss() {
        dismissAnimation()
        dismissKeyboard()
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
    
    @objc func openMaps() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        AppCoordinator.openAppleMaps(event: event)
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
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    
}
// MARK: MapView functionality ------------------------------------------------------------------
extension DetailView : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 2
        return renderer
    }
    
    private func showMaproute() {
        let directionRequest = MKDirections.Request()
        let locationManager = CLLocationManager()
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)))
            routeMap.setRegion(region, animated: true)
        }
        
        if let destinationCoordinates = (event.locationLongitude != nil) ? CLLocationCoordinate2D(latitude: event.locationLatitude!, longitude: event.locationLongitude!) : nil {
            let annotation = MKPointAnnotation()
            annotation.coordinate = destinationCoordinates
            annotation.title = event.locationName ?? ""
            routeMap.addAnnotation(annotation)
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinates))
        } else { return }
        
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            self.routeMap.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            var rect = route.polyline.boundingMapRect
            rect.size = MKMapSize(width: rect.size.width + 100000, height: rect.size.height + 100000)
            rect.origin = MKMapPoint(x: rect.origin.x - 50000, y: rect.origin.y - 50000)
            
            self.routeMap.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

