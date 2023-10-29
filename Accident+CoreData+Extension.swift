//
//  Accident+CoreData+Extension.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 15.09.23.
//

import Foundation
import CoreData
import CoreLocation
import SwiftUI

extension Accident {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
    }
    
    var color: Color {
        guard let unfallTyp1 = UnfallTyp1(rawValue: Int(self.unfallTyp1)) else {
            return Color.gray
        }
        return unfallTyp1.color
    }
}
