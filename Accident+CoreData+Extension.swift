//
//  Accident+CoreData+Extension.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 15.09.23.
//

import Foundation
import CoreData
import CoreLocation

extension Accident {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
    }
}
