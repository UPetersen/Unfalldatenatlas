//
//  DatabaseService.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 29.05.25.
//

import Foundation
import GRDB


extension Bundle {
    static func logMissingResource(name: String, ext: String) -> URL? {
        let url = Bundle.main.url(forResource: name, withExtension: ext)
        if url == nil {
            print("📛 Fehlende Datei: \(name).\(ext)")
            Thread.callStackSymbols.forEach { print("🔍 \($0)") }
        }
        return url
    }
}

/// Handles GRDB sqlite database. Both cases: creation of new database from CSV files (development phase until databes setup is fine) and usage of prefilled database (production use case for end user)
///
/// How to handle database creation (fill up from CSV files and usage of prefilled database.
/// Case A: Create database (development case):
///     Flag/String "-DGRDB_DATABASE_CREATION_MODE_TRUE" needs to be set in „Build Settings“ → „Other Swift Flags“.
///     CSV files need to be marked as having Target Membership for the app (in order to be downloaded as part of the app bundle).. To be done in the file inspector (right panel in xcode). Select all csv files, select the "+" in the target membership area and set the checkmark for Unfalldatenatlas.
///     Once development case is finished and the database setup and content is fine, copy the database to the bundle -> See Case B below.
/// Case B: use prefilled database (production case):
///     Flag /String "-DGRDB_DATABASE_CREATION_MODE_TRUE" must not be set in „Build Settings“ → „Other Swift Flags“. (Can be renamed to e.g. "-DGRDB_DATABASE_CREATION_MODE_FALSE", then tihe "-DGRDB_DATABASE_CREATION_MODE_TRUE" is not existant (and the if clause is kind of considered false).
///     A database that was created using Case A must be put into the bundle. Just the Unfalldaten.sqlite file, nothing else.
///     This file can be copied from the downloaded container (via xcode) from the iPhone or using the mac from /Users/Uwe/Library/Containers/<Dein Bundle Identifier>/Data/Library/Application Support/
///     The database file must be marked as having target membership for the app (in order to be downloaded as part of the app bundle).. To be done in the file inspector (right panel in xcode). Select the databse file, select the "+" in the target membership area and set the checkmark for Unfalldatenatlas.
///
final class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()
//    let dbQueue: DatabaseQueue
    let dbPool: DatabasePool

    private init() {
        



#if GRDB_DATABASE_CREATION_MODE_TRUE
        // CSV-Import, Progress-Bar, usw.
        // To get this mode on needs a setting in Swift other flags wich is the following String: "-DGRDB_DATABASE_CREATION_MODE_TRUE".
        // The "-D" prefix is needed to set the flag value of "GRDB_DATABASE_CREATION_MODE_TRUE"
        print("The following Swift Other Flags is set: -DGRDB_DATABASE_CREATION_MODE_TRUE")
        print("  -> App usage in database creation mode. Database will be created from CSV files.")
#else
        // To get this mode the respective String "-DGRDB_DATABASE_CREATION_MODE_TRUE" in Swift other flags must not exist, e.g. rename it to "-DGRDB_DATABASE_CREATION_MODE_FALSE" for clarity.
        print("The following Swift Other Flags is   N O T   S E T: -DGRDB_DATABASE_CREATION_MODE_TRUE")
        print("  -> App usage in normal mode. Database will be loaded from bundle if necessary.")
#endif
        
        deleteOldCoreDataFilesIfNeeded()

        do {
            let fileManager = FileManager.default
            
            // Determine DB path in Application Support
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            let dbURL = appSupportURL.appendingPathComponent("Unfalldaten.sqlite")

// If the flag is set, the sqlite database will be crated from scratch from the csv files. Copy that database (file Unfalldaten.sqlite) then later into the xcode repository.
// If the flag es not set (#else) the database from the xcode project (bundle) will be used and copied over to the respective folder in the app. If the current version is already in this folder, no copy is necessary. If an older version is already in this folder it will be removed.
#if GRDB_DATABASE_CREATION_MODE_TRUE
            // Remove old DB if exists
            try? fileManager.removeItem(at: dbURL)
#else
            
            // Read bundle version/build
            let bundledDBURL = Bundle.main.url(forResource: "Unfalldaten", withExtension: "sqlite")
            let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
            let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
            
            // Helper to read metadata from DB
            func readDBMetadata(from dbURL: URL) -> (version: String, build: String) {
                do {
                    let dbQueue = try DatabaseQueue(path: dbURL.path)
                    var version = "0"
                    var build = "0"
                    try dbQueue.read { db in
                        version = try String.fetchOne(db, sql: "SELECT value FROM metadata WHERE key = 'db_version'") ?? "0"
                        build = try String.fetchOne(db, sql: "SELECT value FROM metadata WHERE key = 'db_build'") ?? "0"
                    }
                    return (version, build)
                } catch {
                    print("⚠️ Error reading DB metadata: \(error)")
                    return ("0", "0")
                }
            }
            
            var mustCopyDatabase = false
            if !fileManager.fileExists(atPath: dbURL.path) {
                mustCopyDatabase = true
                print("Database does not exist. Need to copy from bundle.")
            } else if bundledDBURL != nil {
                // Compare versions
                let (dbVersion, dbBuild) = readDBMetadata(from: dbURL)
                let bundleTuple = (bundleVersion, bundleBuild)
                let dbTuple = (dbVersion, dbBuild)
                print("DB Version and Build: (\(dbVersion),\(dbBuild)) vs Bundle: (\(bundleVersion),\(bundleBuild))")
                if bundleTuple > dbTuple {
                    mustCopyDatabase = true
                    print("Database on device is older than bundle. Need to copy from bundle.")
                }
            } else {
                print("Database exists and version is same as bundle (or bundle could not be read). No need to copy.")
            }
            
            if mustCopyDatabase {
                // Remove old DB if exists (force copy)
                try? fileManager.removeItem(at: dbURL)
                if let bundledDBURL = bundledDBURL {
                    let startTime = CFAbsoluteTimeGetCurrent()
                    try fileManager.copyItem(at: bundledDBURL, to: dbURL)
                    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                    let sizeMB = Double((try? fileManager.attributesOfItem(atPath: dbURL.path)[.size] as? Int64 ?? 0) ?? 0) / 1024 / 1024
                    print(String(format: "📦 Copied prefilled database from bundle in %.3f seconds (%.1f MB)", elapsed, sizeMB))
                } else {
                    fatalError("❌ Prefilled database not found in bundle!")
                }
            } else {
                print("ℹ️ Existing database is up-to-date.")
            }
            
#endif

            
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
                
                // ... regional information ...
                t.column("land", .integer).notNull()
                t.column("regbez", .integer).notNull()
                t.column("kreis", .integer).notNull()
                t.column("gemeinde", .integer).notNull()
            }
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
    
    func writeBundleVersionToDB() {
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        do {
            try dbPool.write { db in
                try db.execute(sql: """
                    CREATE TABLE IF NOT EXISTS metadata (
                        key TEXT PRIMARY KEY,
                        value TEXT NOT NULL
                    );
                """)
                try db.execute(sql: """
                    INSERT INTO metadata (key, value) VALUES ('db_version', ?) 
                    ON CONFLICT(key) DO UPDATE SET value=excluded.value
                """, arguments: [bundleVersion])
                try db.execute(sql: """
                    INSERT INTO metadata (key, value) VALUES ('db_build', ?) 
                    ON CONFLICT(key) DO UPDATE SET value=excluded.value
                """, arguments: [bundleBuild])
            }
            print("✅ Bundle-Version/Build wurden in die Datenbank geschrieben: \(bundleVersion) / \(bundleBuild)")
        } catch {
            print("❌ Fehler beim Schreiben der Bundle-Version in die DB: \(error)")
        }
    }
}

func deleteOldCoreDataFilesIfNeeded() {
    let fileManager = FileManager.default
    do {
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        let baseName = "Unfalldatenatlas.sqlite" // Passe den Namen ggf. an
        let possibleExtensions = ["", "-shm", "-wal"]
        
        for ext in possibleExtensions {
            let fileURL = appSupportURL.appendingPathComponent(baseName + ext)
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("🗑️ Alte Core Data Datei gelöscht: \(fileURL.lastPathComponent)")
                } catch {
                    print("❌ Fehler beim Löschen von \(fileURL.lastPathComponent): \(error)")
                }
            }
        }
    } catch {
        print("❌ Fehler beim Finden des App-Support-Ordners: \(error)")
    }
}

func deleteOldCSVFiles() {
    let fileManager = FileManager.default
    // Suche im Documents- und Application Support-Verzeichnis nach CSVs
    let directories = [
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
        fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    ]
    
    for directory in directories.compactMap({ $0 }) {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
//            let csvFiles = fileURLs.filter { $0.pathExtension.lowercased() == "csv" }
            let csvFiles = fileURLs.filter { $0.lastPathComponent.hasPrefix("Unfallorte") && $0.pathExtension.lowercased() == "csv" }
            
            for csvFile in csvFiles {
                let start = Date()
                try fileManager.removeItem(at: csvFile)
                let end = Date()
                print("🗑️ Deleted \(csvFile.lastPathComponent) in \(end.timeIntervalSince(start)) seconds")
            }
        } catch {
            print("❌ Fehler beim Löschen der CSV-Dateien im Verzeichnis \(directory.path): \(error)")
        }
    }
}
