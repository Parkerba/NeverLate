//
//  Coordinate.swift
//  Never Late
//
//  Created by parker amundsen on 5/17/20.
//  Copyright © 2020 Parker Buhler Amundsen. All rights reserved.
//

import Foundation
import CoreLocation
struct Coordinate : Codable {
    var latitude: Double
    var longitude: Double
    
    public init(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
    
    public func CLCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
