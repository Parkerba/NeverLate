//
//  MapViewAnnotation.swift
//  Never Late
//
//  Created by parker amundsen on 3/22/20.
//  Copyright © 2020 Parker Buhler Amundsen. All rights reserved.
//

import MapKit

class MapViewAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let subtitle: String?
    let placemark : MKPlacemark
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, placemark: MKPlacemark) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.placemark = placemark
    }
}
