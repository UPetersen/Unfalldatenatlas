////
////  AccidentNeu.swift
////  Unfalldatenatlas
////
////  Created by Uwe Petersen on 29.05.25.
////
//import Foundation
//import GRDB
//
//struct AccidentNeu: Codable, FetchableRecord, PersistableRecord, Identifiable {
//    var id: Int32                     // accidentObjectID
//    var year: Int16
//    var month: Int16
//    var hour: Int16
//    var weekday: Int16
//    var category: Int16
//    var type: Int16
//    var subtype: Int16
//    var lighting: Int16
//    var roadCondition: Int16
//    var vehicleMask: Int16
//    var latitude100: Int32
//    var longitude100: Int32
//
//    var coordinate: (lat: Double, lon: Double) {
//        (
//            Double(latitude100) / 10_000_000,
//            Double(longitude100) / 10_000_000
//        )
//    }
//
//    static let databaseTableName = "accidents_neu"
//}
