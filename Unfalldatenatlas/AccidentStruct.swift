//
//  AccidentStruct.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 19.10.24.
//

import Foundation
import MapKit
import SwiftUI
import CoreData

/// Struct that contains the accident data that is displayed to the user.
///
/// This is a mirror, or say copy, of the core data class Accident which is used by the core data store. Contrary to NSMangedObject's it is Sendable. Introduced when changing to Swift 6.
struct AccidentStruct: Sendable, Identifiable {
//    let id: UUID = UUID()
    let id: NSManagedObjectID
    let accidentObjectID: Int32
    //    let countOfAccidentsBy100000: Int32
    let vehicleMask: Int16
    let jahr: Int16
//    let land: Int16
    let latitude: Double
    let lichtVerhaeltnisse: Int16
    let longitude: Double
    let monat: Int16
    let strassenZustand: Int16
    let stunde: Int16
    let unfallArt: Int16
    let unfallKategorie: Int16
    let unfallTyp1: Int16
    let wochentag: Int16
    let coordinate: CLLocationCoordinate2D
    let color: Color
}
extension AccidentStruct: Equatable {
    static func == (lhs: AccidentStruct, rhs: AccidentStruct) -> Bool {
        lhs.id == rhs.id
    }
}
/// This is a mirror, or say copy, of the core data class Accident which is used by the core data store. Contrary to NSMangedObject's it is Sendable. Introduced when changing to Swift 6.
struct AccidentStructGRDB: Sendable, Identifiable {
//    let id: UUID = UUID()
    let id: Int32
    let accidentObjectID: Int32
    //    let countOfAccidentsBy100000: Int32
    let vehicleMask: Int16
    let jahr: Int16
//    let land: Int16
    let latitude: Double
    let lichtVerhaeltnisse: Int16
    let longitude: Double
    let monat: Int16
    let strassenZustand: Int16
    let stunde: Int16
    let unfallArt: Int16
    let unfallKategorie: Int16
    let unfallTyp1: Int16
    let wochentag: Int16
    let coordinate: CLLocationCoordinate2D
    let color: Color
    
    init(_ record: AccidentNeu) {
        self.id = record.id
        self.accidentObjectID = record.id
        self.vehicleMask = record.vehicleMask
        self.jahr = record.jahr
        self.monat = record.monat
        self.stunde = record.stunde
        self.wochentag = record.wochentag
        self.unfallKategorie = record.unfallKategorie
        self.unfallArt = record.unfallArt
        self.unfallTyp1 = record.unfallTyp1
        self.lichtVerhaeltnisse = record.lichtVerhaeltnisse
        self.strassenZustand = record.strassenZustand
        self.latitude = Double(record.latitude100) / 10_000_000
        self.longitude = Double(record.longitude100) / 10_000_000
        self.coordinate = CLLocationCoordinate2D(
            latitude: self.latitude,
            longitude: self.longitude
        )
        self.color = record.color // Wenn `color` eine Property von `AccidentNeu` ist
    }
}

//extension AccidentStructGRDB {
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//    
//    var color: Color {
//        guard let unfallTyp1 = UnfallTyp1(rawValue: Int(self.unfallTyp1)) else {
//            return Color.gray
//        }
//        return unfallTyp1.color
//    }
//}


extension AccidentStructGRDB: Equatable {
    static func == (lhs: AccidentStructGRDB, rhs: AccidentStructGRDB) -> Bool {
        lhs.id == rhs.id
    }
}
