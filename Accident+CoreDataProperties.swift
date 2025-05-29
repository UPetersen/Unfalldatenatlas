//
//  Accident+CoreDataProperties.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 28.09.23.
//
//

import Foundation
import CoreData


extension Accident {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Accident> {
        return NSFetchRequest<Accident>(entityName: "Accident")
    }

    @NSManaged public var accidentObjectID: Int32
//    @NSManaged public var countOfAccidentsBy100000: Int32
    @NSManaged public var vehicleMask: Int16
    @NSManaged public var jahr: Int16
//    @NSManaged public var land: Int16
    @NSManaged public var lichtVerhaeltnisse: Int16
    @NSManaged public var monat: Int16
    @NSManaged public var strassenZustand: Int16
    @NSManaged public var stunde: Int16
    @NSManaged public var unfallArt: Int16
    @NSManaged public var unfallKategorie: Int16
    @NSManaged public var unfallTyp1: Int16
    @NSManaged public var wochentag: Int16

//    @NSManaged public var lattitude: Double
//    @NSManaged public var longitude: Double
    @NSManaged public var latitudeRaw: Int32
    @NSManaged public var longitudeRaw: Int32
}

extension Accident {
    private static let scale: Double = 10_000_000

    var latitude: Double {
        Double(latitudeRaw) / Accident.scale
    }

    var longitude: Double {
        Double(longitudeRaw) / Accident.scale
    }

    func setCoordinates(lat: Double, lon: Double) {
        latitudeRaw = Int32(lat * Accident.scale)
        longitudeRaw = Int32(lon * Accident.scale)
    }
}

extension Accident : Identifiable {

}

//extension Accident : Sendable {
//    
//}
