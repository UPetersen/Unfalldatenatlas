//
//  MKCoordinateRegion+Extension.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 11.02.23.
//

import Foundation
import MapKit


extension MKCoordinateRegion: @retroactive Equatable
{
   public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool
   {
       if lhs.center.latitude != rhs.center.latitude || lhs.center.longitude != rhs.center.longitude
       {
           return false
       }
       if lhs.span.latitudeDelta != rhs.span.latitudeDelta || lhs.span.longitudeDelta != rhs.span.longitudeDelta
       {
           return false
       }
       return true
   }
    

    var areaInSquareKilometers: Double {
        let span = self.span
        let center = self.center
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let latidueMeters = loc1.distance(from: loc2)
        let longitudeMeters = loc3.distance(from: loc4)
        let area = latidueMeters * longitudeMeters / 1_000_000.0
        return area
    }
    
//    var predicate: NSPredicate  {
//        let longitudeMin = self.center.longitude - 0.5 * self.span.longitudeDelta
//        let longitudeMax = self.center.longitude + 0.5 * self.span.longitudeDelta
//        let lattitudeMin = self.center.latitude - 0.5 * self.span.latitudeDelta
//        let lattitudeMax = self.center.latitude + 0.5 * self.span.latitudeDelta
//
//        let predicateLongMin = NSPredicate(format: "%lf < longitude", longitudeMin)
//        let predicateLongMax = NSPredicate(format: "longitude < %lf", longitudeMax)
//        let predicateLatMin = NSPredicate(format: "%lf < lattitude", lattitudeMin)
//        let predicateLatMax = NSPredicate(format: "lattitude < %lf", lattitudeMax)
//        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongMin, predicateLongMax, predicateLatMin, predicateLatMax])
//
//        return predicate
//    }
    
    /// Gibt ein NSPredicate zurück, das den sichtbaren Bereich in der Karte abdeckt (mit Int32-Indexierung)
    func predicateForRegion(scale: Double = 10_000_000) -> NSPredicate {
        let latMin = center.latitude - span.latitudeDelta * 0.5
        let latMax = center.latitude + span.latitudeDelta * 0.5
        let lonMin = center.longitude - span.longitudeDelta * 0.5
        let lonMax = center.longitude + span.longitudeDelta * 0.5

        let latMinRaw = Int32(latMin * scale)
        let latMaxRaw = Int32(latMax * scale)
        let lonMinRaw = Int32(lonMin * scale)
        let lonMaxRaw = Int32(lonMax * scale)

        return NSPredicate(format: "latitudeRaw BETWEEN {%d, %d} AND longitudeRaw BETWEEN {%d, %d}", latMinRaw, latMaxRaw, lonMinRaw, lonMaxRaw)
    }
    
}
extension MKCoordinateRegion {
    var boundingBox100: (minLat: Int32, maxLat: Int32, minLon: Int32, maxLon: Int32) {
        let latDelta = self.span.latitudeDelta * 0.5
        let lonDelta = self.span.longitudeDelta * 0.5

        let minLat = self.center.latitude - latDelta
        let maxLat = self.center.latitude + latDelta
        let minLon = self.center.longitude - lonDelta
        let maxLon = self.center.longitude + lonDelta
        
        return (
            minLat: Int32(minLat * 10_000_000),
            maxLat: Int32(maxLat * 10_000_000),
            minLon: Int32(minLon * 10_000_000),
            maxLon: Int32(maxLon * 10_000_000)
        )
    }
}

//extension MKCoordinateRegion {
//    var areaInSquareDegrees: Double {
//        return span.latitudeDelta * span.longitudeDelta
//    }
//}
//
//extension MKCoordinateRegion {
//    func isApproximatelyEqualTo(_ other: MKCoordinateRegion, tolerancePercent: Double = 1.0) -> Bool {
//        let oldArea = self.areaInSquareDegrees
//        let newArea = other.areaInSquareDegrees
//        guard oldArea > 0 && newArea > 0 else { return false }
//
//        let areaDelta = abs(newArea - oldArea)
//        let relativeChange = areaDelta / oldArea * 100
//
//        let centerShiftLat = abs(self.center.latitude - other.center.latitude)
//        let centerShiftLon = abs(self.center.longitude - other.center.longitude)
//
//        // Toleranzwert: wenn sich Zentrum UND Fläche nicht stark ändern, ist es "gleich"
//        return relativeChange < tolerancePercent &&
//               centerShiftLat < self.span.latitudeDelta * tolerancePercent / 100 &&
//               centerShiftLon < self.span.longitudeDelta * tolerancePercent / 100
//    }
//}


extension MKCoordinateRegion {
    
    /// Estimates the visible map area's size in "square degrees".
    /// This is a unitless measure useful for comparing relative region size changes
    /// regardless of zoom level or location on Earth.
    var areaInSquareDegrees: Double {
        return span.latitudeDelta * span.longitudeDelta
    }

    /// Compares two coordinate regions with a tolerance percentage.
    ///
    /// Returns `true` if the area size and center position of the regions
    /// differ by less than the given tolerance.
    ///
    /// - Parameters:
    ///   - other: The region to compare with.
    ///   - tolerancePercent: The allowed difference in percent (default: 1.0).
    /// - Returns: `true` if regions are considered approximately equal.
    func isApproximatelyEqual(to other: MKCoordinateRegion, tolerancePercent: Double = 1.0) -> Bool {
        let area1 = self.areaInSquareDegrees
        let area2 = other.areaInSquareDegrees
        
        // Avoid division by zero or nonsensical comparisons
        guard area1 > 0 && area2 > 0 else { return false }

        // Compute relative area change in percent
        let areaDifference = abs(area2 - area1)
        let areaChangePercent = areaDifference / area1 * 100

        // Compute center coordinate difference
        let latShift = abs(center.latitude - other.center.latitude)
        let lonShift = abs(center.longitude - other.center.longitude)

        // Both area and center must be within tolerance to consider equal
        return areaChangePercent < tolerancePercent &&
               latShift < span.latitudeDelta * tolerancePercent / 100 &&
               lonShift < span.longitudeDelta * tolerancePercent / 100
    }
}
