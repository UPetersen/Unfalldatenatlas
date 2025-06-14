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
    var jahr: Int
    var monat: Int
    var stunde: Int
    var wochentag: Int
    var unfallKategorie: Int
    var unfallArt: Int
    var unfallTyp1: Int
//    var lichtVerhaeltnisse: Int16
    var lichtVerhaeltnisse: Int
    var strassenZustand: Int
    var vehicleMask: Int16
    var latitude100: Int32
    var longitude100: Int32
    
    // Regional information (will only be used for filtering)
    var land: Int         // Bundesland (1–16)
    var regbez: Int       // Regierungsbezirk (0–9, mostly 0)
    var kreis: Int        // Kreis (00–99)
    var gemeinde: Int    // Gemeinde (000–999)

    static let databaseTableName = "accidents"
}

