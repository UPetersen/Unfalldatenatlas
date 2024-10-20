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

struct AccidentStruct: Sendable, Identifiable {
//    let id: UUID = UUID()
    let id: NSManagedObjectID
    let accidentObjectID: Int32
    //    let countOfAccidentsBy100000: Int32
    let istFahrrad: Bool
    let istFussgaenger: Bool
    let istGueterKfz: Bool
    let istKrad: Bool
    let istPkw: Bool
    let istSonstige: Bool
    let jahr: Int16
    let land: Int16
    let lattitude: Double
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
