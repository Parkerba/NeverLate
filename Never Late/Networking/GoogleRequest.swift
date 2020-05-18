//
//  GoogleRequest.swift
//  Never Late
//
//  Created by parker amundsen on 9/12/19.
//  Copyright © 2019 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

// Used to encapsolate the needed data from the google matrix api call
struct googleData {
    var driveTimeInTraffic: Int // Drive time accounting for traffic
    var driveTime: Int // Drive time with no traffic
    var distance: Int // Distance of the route
}

// Class used to perform requests to the Google distance Matrix api
final class GoogleRequest {
    // Used to limit number of API calls in a request
    static private var apiCalls = 0
    
    static private let basePath = "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
    
    static private let distanceMatrixAPIKey = "YourAPIKey"
    
    // returns the completed URL path to be requested
    static public func getDriveTimeUrl(event: Event) -> URL? {
        if eventContainsNilLocations(event: event) {return nil}
        
        let departureTimeInSeconds : Int = Int(event.departureTime?.timeIntervalSince1970 ?? event.date.timeIntervalSince1970)
        
        let returnUrl: String = "\(basePath)\(event.startingPosition!.latitude),\(event.startingPosition!.longitude)&destinations=\(event.destinationPosition!.latitude),\(event.destinationPosition!.longitude)&departure_time=\(departureTimeInSeconds)&traffic_model=best_guess&key=\(distanceMatrixAPIKey)"
        return URL(string: returnUrl)
    }
    
    // Checks for nil location values in event param
    static public func eventContainsNilLocations(event: Event) -> Bool {
        guard let _ = event.startingPosition, let _ = event.destinationPosition else {
            return true
        }
        return false
    }
    
    // Preforms the URLSession request.
    // Recursive function, makes api calls until the the accuracy is sufficient,
    // or until number of api calls reach the specified max in the constants file.
    static func performRequest(url: URL?, event: Event) {
        guard let url = url else {return}
        var event = event
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                if let driveTimeData = parseJson(json: data) {
                    print(GoogleRequest.apiCalls)
                    GoogleRequest.apiCalls += 1
                    event.setDriveTime(driveTime: driveTimeData.driveTimeInTraffic)
                    if (event.departureTime == nil) {
                        event.setDepartureTime(departureTime: event.date)
                    }
                    guard let accuracy = getAccuracy(event: event) else {
                        return
                    }
                    checkAccuracy(offBy: accuracy, event: event)
                    return
                }
            } else {
                // There has been a network error, notify the user.
                DispatchQueue.main.async {
                    let networkError = Notification.Name("networkError")
                    NotificationCenter.default.post(name: networkError, object: nil)
                }
            }
        }.resume()
    }
    
    
    // returns the number of seconds that the departure time is off by, used to improve the departure time prediction for the next api call.
    static private func getAccuracy(event: Event) -> Int? {
        let estimatedArrivalInSeconds : Int = Int(event.departureTime!.timeIntervalSince1970) + event.driveTime! 
        return estimatedArrivalInSeconds - Int(event.date.timeIntervalSince1970)
    }
    
    // Determines if the departure time from the api call is accurate enough (within 5 minutes early but never late)
    static private func checkAccuracy(offBy: Int, event: Event) {
        var event = event
        if (offBy > Constants.earlyArrivalToleranceInSeconds || offBy < 0) && apiCalls <= Constants.maximumAPICalls {
            event.setDepartureTime(departureTime: event.departureTime?.addingTimeInterval(-Double(offBy)) ?? event.date.addingTimeInterval(Double(offBy)))
            let url = getDriveTimeUrl(event: event)
            performRequest(url: url, event: event)
            return
        }
        finalizeEvent(event: event)
    }
    
    // Called when the accuracy is determined to be sufficient or api calls exceed 5
    static private func finalizeEvent(event: Event) {
        print("Finished request with after performing \(apiCalls) api calls")
        apiCalls = 0
        AppCoordinator.saveEvent(event: event)
        AppCoordinator.addNotification(event: event)
        sendDriveTimeNotification()
    }
    
    // Sends out a notification to reload the eventTable of the entryViewController
    static private func sendDriveTimeNotification() {
        let name = Notification.Name(rawValue: "reloadEvents")
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    // This parses the json returned from the google distance matrix api call
    static private func parseJson (json: Data?) -> googleData? {
        guard let jsonData = json else {
            return nil
        }
        var distanceInformation = googleData(driveTimeInTraffic: 0, driveTime: 0, distance: 0)
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if let rows =  jsonObject["rows"] as? Array<Dictionary<String, Any>> {
                    
                    if (rows.count == 0) {
                        // Invalid request notify the user
                        DispatchQueue.main.async {
                            let invalidRequest = Notification.Name("invalidRequest")
                            NotificationCenter.default.post(name: invalidRequest, object: nil)
                        }
                        return nil
                    }
                    
                    let dictObject = rows[0]
                    if let elements = dictObject["elements"] as? Array<Dictionary<String, Any>> {
                        
                        if let distanceInfo = elements[0]["distance"] as? Dictionary<String, Any> {
                            if let distance = distanceInfo["value"] as? Int {
                                distanceInformation.distance = distance
                            }
                            
                            if let trafficInfo  = elements[0]["duration_in_traffic"] as? Dictionary<String, Any> {
                                if let driveTimeInTraffic = trafficInfo["value"] as? Int {
                                    distanceInformation.driveTimeInTraffic = driveTimeInTraffic
                                }
                            }
                            
                            if let normalDriveTime = elements[0]["duration"] as? Dictionary<String, Any> {
                                if let driveTime = normalDriveTime["value"] as? Int {
                                    distanceInformation.driveTime = driveTime
                                    return distanceInformation
                                }
                            }
                        }
                    }
                }
            }
        }
            
        catch let error {
            print (error.localizedDescription)
            print ("There has been an error parsing the json")
            return nil
        }
        return nil
    }
}
