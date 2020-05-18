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
    // User given name
    var title: String
    
    var startingPosition: Coordinate?
    var destinationPosition: Coordinate?
    
    var locationName: String?
    
    var driveTime: Int?
    var departureTime: Date?
    var date: Date
    var eventDescription: String
    var eventIdentifier: UUID
    var offset: Int = 0
    
    // initializer taking a date param
    init (datePicked: Date, eventName: String, eventLocation: MKPlacemark?, EventDescription: String ) {
        date = datePicked
        locationName = eventLocation?.name
        title = eventName
        eventDescription = EventDescription
        
        if let eventLocation = eventLocation {
            destinationPosition = Coordinate(coordinate: eventLocation.coordinate)
        }
        
        eventIdentifier = UUID()
    }
    
    init (datePicked: Date, eventName: String, eventLocation: MKPlacemark?, currentLocation: CLLocationCoordinate2D?, EventDescription: String ) {
        date = datePicked
        locationName = eventLocation?.name
        title = eventName
        eventDescription = EventDescription
        
        if let eventLocation = eventLocation {
            destinationPosition = Coordinate(coordinate: eventLocation.coordinate)
        }
        
        if let currentLocation = currentLocation {
            startingPosition = Coordinate(coordinate: currentLocation)
        }
        
        eventIdentifier = UUID()
    }
    
    //------------------------------------------------------------------------------
    
    func saveEvent() {
        EventManager.save(object: self, with: eventIdentifier.uuidString)
    }
    
    func deleteEvent() {
        EventManager.delete(eventIdentifier.uuidString)
    }
    mutating func setOffset(offset: Int) {
        self.offset = offset
    }
    
    mutating func setDriveTime(driveTime: Int) {
        self.driveTime = driveTime
    }
    
    mutating func setDepartureTime(departureTime: Date) {
        self.departureTime = departureTime
    }
}
