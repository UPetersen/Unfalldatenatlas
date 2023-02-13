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
}
