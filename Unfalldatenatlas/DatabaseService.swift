//
//  DatabaseService.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 29.05.25.
//

import Foundation
import GRDB

final class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()
//    let dbQueue: DatabaseQueue
    let dbPool: DatabasePool

    private init() {

        do {
            let fileManager = FileManager.default
            
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            let dbURL = appSupportURL.appendingPathComponent("Unfalldaten.sqlite")
            
//            // Wenn Datei nicht existiert → aus Bundle kopieren
//            if !fileManager.fileExists(atPath: dbURL.path) {
//                guard let bundledDB = Bundle.main.url(forResource: "Unfalldaten", withExtension: "sqlite") else {
//                    fatalError("Vorgefüllte Datenbank im Bundle nicht gefunden.")
//                }
//                try fileManager.copyItem(at: bundledDB, to: dbURL)
//                print("📦 Vorgefüllte Datenbank aus Bundle kopiert.")
//            }
            
            var config = Configuration()
            config.prepareDatabase { db in
                try db.execute(sql: """
                    PRAGMA temp_store = MEMORY;
                    PRAGMA cache_size = -50000;
                """)
            }
            
            dbPool = try DatabasePool(path: dbURL.path, configuration: config)
            
            try dbPool.read { db in
                let journalMode: String = try String.fetchOne(db, sql: "PRAGMA journal_mode;") ?? "?"
                let synchronous: Int = try Int.fetchOne(db, sql: "PRAGMA synchronous;") ?? -1
                let tempStore: Int = try Int.fetchOne(db, sql: "PRAGMA temp_store;") ?? -1
                let cacheSize: Int = try Int.fetchOne(db, sql: "PRAGMA cache_size;") ?? -1
                let pageSize: Int = try Int.fetchOne(db, sql: "PRAGMA page_size;") ?? -1
                let lockingMode: String = try String.fetchOne(db, sql: "PRAGMA locking_mode;") ?? "?"

                print("journal_mode: \(journalMode)")
                print("synchronous: \(synchronous)")
                print("temp_store: \(tempStore)")
                print("cache_size: \(cacheSize)")
                print("page_size: \(pageSize)")
                print("locking_mode: \(lockingMode)")
            }

            try migrator.migrate(dbPool)
        } catch {
            fatalError("Fehler bei Initialisierung der DB: \(error)")
        }
    }

    /// Datenbankmigrationen: initiales Setup + spätere Änderungen
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // Migration: Erste Version mit Tabelle "unfall"
        migrator.registerMigration("v1_initial") { db in
            let tableName = "accidents"
            try db.create(table: tableName, ifNotExists: true) { t in
                t.column("id", .integer).primaryKey()
                t.column("jahr", .integer).notNull()
                t.column("monat", .integer).notNull()
                t.column("stunde", .integer).notNull()
                t.column("wochentag", .integer).notNull()
                t.column("unfallKategorie", .integer).notNull()
                t.column("unfallArt", .integer).notNull()
                t.column("unfallTyp1", .integer).notNull()
                t.column("lichtVerhaeltnisse", .integer).notNull()
                t.column("strassenZustand", .integer).notNull()
                t.column("vehicleMask", .integer).notNull()
                t.column("latitude100", .integer).notNull()
                t.column("longitude100", .integer).notNull()
            }

            // Indexes
//            try db.create(index: "idx_lon_lat", on: tableName, columns: ["longitude100", "latitude100"])
//            try db.create(index: "idx_jahr", on: tableName, columns: ["jahr"])
        }

        // Weitere Migrationen (Beispiel)
        /*
        migrator.registerMigration("v2_add_column_xyz") { db in
            try db.alter(table: "unfall") { t in
                t.add(column: "neueSpalte", .integer).notNull().defaults(to: 0)
            }
        }
        */

        return migrator
    }
}


// Merken:
//func schreibeUnfall(_ unfall: AccidentNeu) async throws {
//    try await DatabaseService.shared.dbQueue.write { db in
//        try unfall.insert(db)
//    }
//}
//func schreibeUnfaelle(_ unfaelle: [AccidentNeu]) async throws {
//    try await DatabaseService.shared.dbQueue.write { db in
//        for unfall in unfaelle {
//            try unfall.insert(db)
//        }
//    }
//}


//func ladeAlleUnfaelle() async throws -> [AccidentNeu] {
//    try await DatabaseService.shared.dbQueue.read { db in
//        try AccidentNeu.fetchAll(db)
//    }
//}
//func ladeUnfaelle(jahr: Int, vehicleMask: Int) async throws -> [AccidentNeu] {
//    try await DatabaseService.shared.dbQueue.read { db in
//        try AccidentNeu
//            .filter(Column("jahr") == jahr && Column("vehicleMask").bitwiseAnd(vehicleMask) != 0)
//            .fetchAll(db)
//    }
//}






//final class DatabaseService: @unchecked Sendable {
//    static let shared = DatabaseService()
//    let dbQueue: DatabaseQueue
//
//    private init() {
//        let pfad = FileManager.default
//            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
//            .first!
//            .appendingPathComponent("Unfalldaten.sqlite")
//
//        do {
//            dbQueue = try DatabaseQueue(path: pfad.path)
//
//            try dbQueue.write { db in
//                try db.create(table: AccidentNeu.databaseTableName, ifNotExists: true) { t in
//                    t.column("id", .integer).primaryKey()
//                    t.column("jahr", .integer).notNull()
//                    t.column("monat", .integer).notNull()
//                    t.column("stunde", .integer).notNull()
//                    t.column("wochentag", .integer).notNull()
//                    t.column("unfallKategorie", .integer).notNull()
//                    t.column("unfallArt", .integer).notNull()
//                    t.column("unfallTyp1", .integer).notNull()
//                    t.column("lichtVerhaeltnisse", .integer).notNull()
//                    t.column("strassenZustand", .integer).notNull()
//                    t.column("vehicleMask", .integer).notNull()
//                    t.column("latitude100", .integer).notNull()     // zentimetergenau
//                    t.column("longitude100", .integer).notNull()     // zentimetergenau
////                    t.column("accidentObjectID", .integer).notNull()
////                    t.index(["longitude100", "latitude100"])
////                    t.index(["id"])
//                }
//
//                try db.create(index: "idx_lon_lat", on: AccidentNeu.databaseTableName, columns: ["longitude100", "latitude100"])
//                try db.create(index: "idx_jahr", on: AccidentNeu.databaseTableName, columns: ["jahr"])
////                try db.createIndex("idx_lon_lat", on: "unfall", columns: ["longitude100", "latitude100"])
////                try db.createIndex("idx_objectid", on: "unfall", columns: ["accidentObjectID"])
//            }
//        } catch {
//            fatalError("Fehler bei Initialisierung der DB: \(error)")
//        }
//    }
//}
