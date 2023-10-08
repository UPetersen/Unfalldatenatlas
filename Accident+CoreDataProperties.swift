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
    @NSManaged public var countOfAccidentsBy100000: Int32
    @NSManaged public var istFahrrad: Bool
    @NSManaged public var istFussgaenger: Bool
    @NSManaged public var istGueterKfz: Bool
    @NSManaged public var istKrad: Bool
    @NSManaged public var istPkw: Bool
    @NSManaged public var istSonstige: Bool
    @NSManaged public var jahr: Int16
    @NSManaged public var land: Int16
    @NSManaged public var lattitude: Double
    @NSManaged public var lichtVerhaeltnisse: Int16
    @NSManaged public var longitude: Double
    @NSManaged public var monat: Int16
    @NSManaged public var strassenZustand: Int16
    @NSManaged public var stunde: Int16
    @NSManaged public var unfallArt: Int16
    @NSManaged public var unfallKategorie: Int16
    @NSManaged public var unfallTyp1: Int16
    @NSManaged public var wochentag: Int16

}

extension Accident : Identifiable {

}
