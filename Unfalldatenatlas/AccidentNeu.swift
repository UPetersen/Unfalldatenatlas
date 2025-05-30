//
//  AccidentNeu.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 29.05.25.
//
import Foundation
import GRDB

struct AccidentNeu: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: Int32                     // accidentObjectID
    var jahr: Int16
    var monat: Int16
    var stunde: Int16
    var wochentag: Int16
    var unfallKategorie: Int16
    var unfallArt: Int16
    var unfallTyp1: Int16
    var lichtVerhaeltnisse: Int16
    var strassenZustand: Int16
    var vehicleMask: Int16
    var latitude100: Int32
    var longitude100: Int32

    var coordinate: (lat: Double, lon: Double) {
        (
            Double(latitude100) / 10_000_000,
            Double(longitude100) / 10_000_000
        )
    }

    static let databaseTableName = "accidents"
}
