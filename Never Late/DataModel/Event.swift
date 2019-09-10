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
    
    // initializer taking a date param
    init (datePicked: Date, eventName: String, eventLocation: MKPlacemark?, EventDescription: String ) {
        eventDate = datePicked
        locationName = eventLocation?.name
        locationLatitude = eventLocation?.coordinate.latitude
        locationLongitude = eventLocation?.coordinate.longitude
        title = eventName
        eventDescription = EventDescription
        eventIdentifier = UUID()
    }

    
    var title: String
    
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationName: String?
    // This is the date of the event chosen by the user
    var eventDate: Date
    var eventDescription: String
    var eventIdentifier: UUID
    
  
    //------------------------------------------------------------------------------

    
    func saveEvent() {
        EventManager.save(object: self, with: eventIdentifier.uuidString)
    }
    
    func deleteEvent() {
        EventManager.delete(eventIdentifier.uuidString)
    }
    
    
 //------------------------------------------------------------------------------
    
    
    
    func currentTime() -> String {
        // current date
        let date = Date()
        // The gap in seconds between now and the eventDate
        let diff = eventDate.timeIntervalSince(date)
        
        let oneWeekInSeconds = 60 * 60 * 24 * 7
        
        // If the event week is more than 1 week out of now, give the eventDate
        if (diff >= Double(oneWeekInSeconds)) {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: eventDate)
            let day = calendar.component(.day, from: eventDate)
            let hour = calendar.component(.hour, from:  eventDate)
            let minutes = calendar.component(.minute, from: eventDate)
            return "\(month) \(day) \(hour):\(minutes)"
        }
            // Give the countdown until the date
        else {
            let days : Int = Int(diff/86400)
            let hours: Int = Int(diff/3600) - days * 24
            let minutes  = Int(diff/60)%60
            return "Days:\(days) Hours:\(hours) Min: \(minutes)  "
        }
    }
}
