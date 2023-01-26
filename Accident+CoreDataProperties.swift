//
//  Accident+CoreDataProperties.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 22.01.23.
//
//

import Foundation
import CoreData
import CoreLocation


extension Accident {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Accident> {
        return NSFetchRequest<Accident>(entityName: "Accident")
    }

    @NSManaged public var accidentObjectID: Int32
    @NSManaged public var gemeinde: Int16
    @NSManaged public var identStlae: String
    @NSManaged public var istFahrrad: Bool
    @NSManaged public var istFussgaenger: Bool
    @NSManaged public var istGueterKfz: Bool
    @NSManaged public var istKrad: Bool
    @NSManaged public var istPkw: Bool
    @NSManaged public var istSonstige: Bool
    @NSManaged public var jahr: Int16
    @NSManaged public var kreis: Int16
    @NSManaged public var land: Int16
    @NSManaged public var lattitude: Double
    @NSManaged public var lichtVerhaeltnisse: Int16
    @NSManaged public var lineRefX: Double
    @NSManaged public var lineRefY: Double
    @NSManaged public var longitude: Double
    @NSManaged public var monat: Int16
    @NSManaged public var regierungsBezirk: Int16
    @NSManaged public var strassenZustand: Int16
    @NSManaged public var stunde: Int16
    @NSManaged public var unfallArt: Int16
    @NSManaged public var unfallKategorie: Int16
    @NSManaged public var unfallTyp1: Int16
    @NSManaged public var wochentag: Int16

}

extension Accident : Identifiable {

}

extension Accident {
    var coordinate: CLLocationCoordinate2D {
      CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
    }

}
