////
////  DatabaseManager.swift
////  Unfalldatenatlas
////
////  Created by Uwe Petersen on 29.05.25.
////
//
//import Foundation
//import GRDB
//
//struct DatabaseManager: Sendable {
//    private let dbQueue: DatabaseQueue
//
//    init(databaseURL: URL) throws {
//        dbQueue = try DatabaseQueue(path: databaseURL.path)
//    }
//
//    func createTablesIfNeeded() throws {
//        try dbQueue.write { db in
//            try db.create(table: AccidentNeu.databaseTableName, ifNotExists: true) { t in
//                t.column("id", .integer).primaryKey()
//                t.column("year", .integer)
//                t.column("month", .integer)
//                t.column("hour", .integer)
//                t.column("weekday", .integer)
//                t.column("category", .integer)
//                t.column("type", .integer)
//                t.column("subtype", .integer)
//                t.column("lighting", .integer)
//                t.column("roadCondition", .integer)
//                t.column("vehicleMask", .integer)
//                t.column("latitude100", .integer)
//                t.column("longitude100", .integer)
//            }
//        }
//    }
//
//    func importAccidentsNeuAsync(from lines: [String]) async throws {
//        try await dbQueue.write { db in
//            for line in lines {
//                let columns = line.components(separatedBy: ";")
//                guard columns.count >= 25 else { continue }
//
//                let lat = Int32(Double(columns[24].replacingOccurrences(of: ",", with: "."))! * 10_000_000)
//                let lon = Int32(Double(columns[23].replacingOccurrences(of: ",", with: "."))! * 10_000_000)
//
//                var vehicleMask: Int16 = 0
//                if columns[15] == "1" { vehicleMask |= 1 << 0 }
//                if columns[16] == "1" { vehicleMask |= 1 << 1 }
//                if columns[17] == "1" { vehicleMask |= 1 << 2 }
//                if columns[18] == "1" { vehicleMask |= 1 << 3 }
//                if columns[19] == "1" { vehicleMask |= 1 << 4 }
//                if columns[20] == "1" { vehicleMask |= 1 << 5 }
//
//                let accident = AccidentNeu(
//                    id: Int32(columns[0])!,
//                    year: Int16(columns[6])!,
//                    month: Int16(columns[7])!,
//                    hour: Int16(columns[8])!,
//                    weekday: Int16(columns[9])!,
//                    category: Int16(columns[10])!,
//                    type: Int16(columns[11])!,
//                    subtype: Int16(columns[12])!,
//                    lighting: Int16(columns[13])!,
//                    roadCondition: Int16(columns[14])!,
//                    vehicleMask: vehicleMask,
//                    latitude100: lat,
//                    longitude100: lon
//                )
//
//                try accident.insert(db)
//            }
//        }
//    }
//}
