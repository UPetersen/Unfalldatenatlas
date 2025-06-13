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
import GRDB

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
/// Accident data needed for displaying on the map. This is what is fetched from the data base and it is a subset of what is stored in the data base.
/// E.g. land is stored in the database but only used for filtering (using SQL). Thus, land will not be fetched and is not contained in this struct. The same accounts for regBez, kreis and gemeinde.
//struct AccidentStructGRDB: Sendable, Identifiable {
struct AccidentStructGRDB: FetchableRecord, TableRecord, Decodable, Sendable, Identifiable {

    let id: Int32
    let vehicleMask: Int16
    let jahr: Int16
    let latitude100: Int32
    let lichtVerhaeltnisse: Int16
    let longitude100: Int32
    let monat: Int16
    let strassenZustand: Int16
    let stunde: Int16
    let unfallArt: Int16
    let unfallKategorie: Int16
    let unfallTyp1: Int16
    let wochentag: Int16
    
    static let databaseTableName = "accidents"

    // Computed Properties:
    var latitude: Double { Double(latitude100) / 10_000_000 }
    var longitude: Double { Double(longitude100) / 10_000_000 }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var color: Color {
        UnfallTyp1(rawValue: Int(self.unfallTyp1))?.color ?? .gray
    }
    
    init(_ record: AccidentNeu) {
        self.id = record.id
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

        self.latitude100 = record.latitude100
        self.longitude100 = record.longitude100
    }
    
    var  symbolString: String {

        // Type of vehicles/persones involved. https://www.destatis.de/DE/ Themen/Gesellschaft- Umwelt/Verkehrsunfaelle/M ethoden/_inhalt.html#sprg37 1798
        // Güterkraffahrzeuge: Unfall mit Güterkraftfahrzeug (GKFZ): Unfall, an dem mindestens ein Lastkraftwagen mit
        // Normalaufbau und einem Gesamtgewicht über 3,5 t, ein Lastkraftwagen mit Tankauflage bzw. Spezialaufbau,
        // eine Sattelzugmaschine oder eine andere Zugmaschine beteiligt war (diese Kategorie ist in
        // den Jahren 2016 und 2017 in "Unfall mit Sonstigen" enthalten)
        // Unfall mit Sonstigen: Unfall, an dem mindestens ein oben nicht genanntes Verkehrsmittel beteiligt war, wie
        // z. B. ein Bus oder eine Straßenbahn (2016 und 2017 einschließlich Unfall mit Güterkraftfahrzeug (GKFZ),
        // ab 2018 ohne Unfall mit GKFZ)

        var symbol: String = ""
        
        symbol.append("\(stunde)\("h,")\(["So","Mo", "Di", "Mi", "Do", "Fr", "Sa"][Int(wochentag) - 1])\(",")\(["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"][Int(monat) - 1])\(jahr - 2000)")
        
        let mask = VehicleMask(rawValue: vehicleMask)
        if mask.contains(.pkw)         { symbol.append("🚗") }
        if mask.contains(.fahrrad)     { symbol.append("🚲") }
        if mask.contains(.fussgaenger) { symbol.append("🚶") }
        if mask.contains(.krad)        { symbol.append("🏍") }
        if mask.contains(.gueterKfz)   { symbol.append("🚚") }
        if mask.contains(.sonstige)    {
            if jahr >= 2018 {
                symbol.append("🚌/🚃")
            } else {
                symbol.append("🚚/🚌/🚃")
            }
        }
        
        // Light Conditions, not icon for twilight (Dämmerung) available, so just made it night, too.
        if lichtVerhaeltnisse == 1 {
            symbol.append("🌛") // Dämmerung/Twilight (did not find any good icon)
        } else if lichtVerhaeltnisse == 2 {
            symbol.append("🌝")  // Dunkelheit/Darkness
        }
        
        // Road conditions
        if strassenZustand == 1 {
            symbol.append("🌧️")
        } else if strassenZustand == 2 {
            symbol.append("❄️")
        }
        
        //Accident Category (Unfallkategorie): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        switch unfallKategorie {
        case 1: symbol.append("✟")
        case 2: symbol.append("🏥")
        case 3: symbol.append("🩹")
        default: fatalError("Wrong Unfallkategorie: \(unfallKategorie). Must be 1, 2 or 3.")
        }
     
        // Accident kind (Unfallart): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Zusammenstoß mit anfahrendem/ anhaltendem/ruhendem Fahrzeug
        // 2 = Zusammenstoß mit vorausfahrendem / wartendem Fahrzeug
        // 3 = Zusammenstoß mit seitlich in gleicher Richtung fahrendem Fahrzeug
        // 4 = Zusammenstoß mit entgegenkommendem Fahrzeug
        // 5 = Zusammenstoß mit einbiegendem / kreuzendem Fahrzeug
        // 6 = Zusammenstoß zwischen Fahrzeug und Fußgänger
        // 7 = Aufprall auf Fahrbahnhindernis
        // 8 = Abkommen von Fahrbahn nach rechts
        // 9 = Abkommen von Fahrbahn nach links Unfall
        // 0 = anderer Art
        symbol.append("A\(unfallArt)")
        
        // Accident type (Unfalltyp1): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Fahrunfall (grün)
        // 2 = Abbiegeunfall (gelb)
        // 3 = Einbiegen / Kreuzen-Unfall (rot)
        // 4 = Überschreiten-Unfall (weiß)
        // 5 = Unfall durch ruhenden Verkehr (blau)
        // 6 = Unfall im Längsverkehr (orange)
        // 7 = sonstiger Unfall (schwarz)
//        symbol.append("T\(accident.unfallTyp1)")
        
        return symbol
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
