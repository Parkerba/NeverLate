//
//  Event.swift
//  Never Late
//
//  Created by parker amundsen on 7/17/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

struct Event: Codable {
    
    var title: String
       
    var currentLatitude: Double?
    var currentLongitude: Double?
       
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationName: String?
    var driveTime: Int?
    var departureTime: Date?
    var eventDate: Date
    var eventDescription: String
    var eventIdentifier: UUID
    
    // initializer taking a date param
    init (datePicked: Date, eventName: String, eventLocation: MKPlacemark?, EventDescription: String ) {
        eventDate = datePicked
        locationName = eventLocation?.name
        title = eventName
        eventDescription = EventDescription
        
        locationLatitude = eventLocation?.coordinate.latitude
        locationLongitude = eventLocation?.coordinate.longitude
       
        eventIdentifier = UUID()
    }
    
    init (datePicked: Date, eventName: String, eventLocation: MKPlacemark?, currentLocation: CLLocationCoordinate2D?, EventDescription: String ) {
        eventDate = datePicked
        locationName = eventLocation?.name
        title = eventName
        eventDescription = EventDescription
        
        currentLatitude = currentLocation?.latitude
        currentLongitude = currentLocation?.longitude
        
        locationLatitude = eventLocation?.coordinate.latitude
        locationLongitude = eventLocation?.coordinate.longitude
       
        eventIdentifier = UUID()
    }

    //------------------------------------------------------------------------------

    func saveEvent() {
        EventManager.save(object: self, with: eventIdentifier.uuidString)
    }
    
    func deleteEvent() {
        EventManager.delete(eventIdentifier.uuidString)
    }
    
    mutating func setDriveTime(driveTime: Int) {
        self.driveTime = driveTime
    }
    
    mutating func setDepartureTime(departureTime: Date) {
        self.departureTime = departureTime
    }
}
