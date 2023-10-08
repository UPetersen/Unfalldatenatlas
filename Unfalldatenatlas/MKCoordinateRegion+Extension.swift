//
//  MKCoordinateRegion+Extension.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 11.02.23.
//

import Foundation
import MapKit


extension MKCoordinateRegion: Equatable
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
    
    var predicate: NSPredicate  {
        let longitudeMin = self.center.longitude - 0.5 * self.span.longitudeDelta
        let longitudeMax = self.center.longitude + 0.5 * self.span.longitudeDelta
        let lattitudeMin = self.center.latitude - 0.5 * self.span.latitudeDelta
        let lattitudeMax = self.center.latitude + 0.5 * self.span.latitudeDelta

        let predicateLongMin = NSPredicate(format: "%lf < longitude", longitudeMin)
        let predicateLongMax = NSPredicate(format: "longitude < %lf", longitudeMax)
        let predicateLatMin = NSPredicate(format: "%lf < lattitude", lattitudeMin)
        let predicateLatMax = NSPredicate(format: "lattitude < %lf", lattitudeMax)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongMin, predicateLongMax, predicateLatMin, predicateLatMax])

        return predicate
    }
}
