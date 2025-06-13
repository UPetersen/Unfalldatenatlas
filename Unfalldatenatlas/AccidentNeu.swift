//
//  AccidentNeu.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 29.05.25.
//
import Foundation
import SwiftUI
import GRDB

/// Used for writing the data from the csv tables into the database.
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
    
    // Regional information (will only be used for filtering)
    var land: UInt8         // Bundesland (1–16)
    var regbez: UInt8       // Regierungsbezirk (0–9, mostly 0)
    var kreis: UInt8        // Kreis (00–99)
    var gemeinde: UInt16    // Gemeinde (000–999)

    static let databaseTableName = "accidents"
}

