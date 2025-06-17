//
//  InitalizationViewModel.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 05.02.23.
//
// Number in line, name, sample data (different for each year)
//   0           1                    2                 3                4
//   OBJECTID    UIDENTSTLAE          ULAND             UREGBEZ          UKREIS
//   81151       8210725416010020000  8                 1                16
//
//   5           6                    7                 8                9
//   UGEMEINDE   UJAHR                UMONAT            USTUNDE          UWOCHENTAG
//   78          2021                 7                 0                1
//
//   10          11                   12                13               14
//   UKATEGORIE  UART                 UTYP1             ULICHTVERH       USTRZUSTAND
//   2           8                    1                 2                1
//
//   15          16                   17                18               19
//   IstRad      IstPKW               IstFuss           IstKrad          IstGkfz
//   0           1                    0                 0                0
//
//   20          21                   22                23               24
//   IstSonstige LINREFX              LINREFY           XGCSWGS84        YGCSWGS84
//   0           509497,179245107     5392224,05191507 9,12902797500004 48,682987865
//
// Vergleich Unfälle mit Personenschaden insgesamt laut Destatis (Obermenge der Daten des Unfalldatenatlas) und Daten des Unfalldatenatlas:
// Jahr:                       2019       2020       2021       2022      2023
// Unfälle mit Personenschaden 300_143    264_499    258_987    289_672,    ?
// Unfälle im Unfalldatenatlas 268_370,   237_994, " 233_208,   256_492,  269_048
//
// Unfälle in der App insgesamt mit Daten von 2016 bis einschlie0ßlich 2023: 1_823_882 (Mit Daten von 2016 einschließlich 2022: 1_554_834)
// Unfälle pro Jahr:
//   ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]
//
// Mapping aller Jahre:
//   Jahr   id  jahr monat stunde wochentag    unfallKategorie    unfallArt    unfallTyp1    lichtVerhaeltnisse    strassenZustand    vehicleFlags    latitude    longitude
//   2016    1    6    7    8     9      10    11    12    13    14    {'fahrrad': 15, 'pkw': 16, 'fussgaenger': 17, 'krad': 18, 'gueterKfz': 19, 'sonstige': 20}    24    23
//   2017    0    6    7    8     9      10    11    12    18    19    {'fahrrad': 13, 'pkw': 14, 'fussgaenger': 15, 'krad': 16, 'sonstige': 17}                     23    22
//   2018    0    5    6    7     8       9    10    11    12    19    {'fahrrad': 13, 'pkw': 14, 'fussgaenger': 15, 'krad': 16, 'gueterKfz': 17, 'sonstige': 18}    23    22
//   2019    0    5    6    7     8       9    10    11    12    23    {'fahrrad': 13, 'pkw': 14, 'fussgaenger': 15, 'krad': 16, 'gueterKfz': 17, 'sonstige': 18}    22    21
//   2020    0    6    7    8     9      10    11    12    13    24    {'fahrrad': 14, 'pkw': 15, 'fussgaenger': 16, 'krad': 17, 'gueterKfz': 18, 'sonstige': 19}    23    22
//   2021    0    6    7    8     9      10    11    12    13    14    {'fahrrad': 15, 'pkw': 16, 'fussgaenger': 17, 'krad': 18, 'gueterKfz': 19, 'sonstige': 20}    24    23
//   2022    0    6    7    8     9      10    11    12    13    14    {'fahrrad': 15, 'pkw': 16, 'fussgaenger': 17, 'krad': 18, 'gueterKfz': 19, 'sonstige': 20}    24    23
//   2023    0    6    7    8     9      10    11    12    13    14    {'fahrrad': 15, 'pkw': 16, 'fussgaenger': 17, 'krad': 18, 'gueterKfz': 19, 'sonstige': 20}    24    23

import Foundation
import CoreData
import GRDB

enum InitializationState: Equatable {
    case initializationRequired
    //    case clearingDatabase
    case loadingData(year: String)
    case importingData(year: String)
    case initalized
    
    var text: String {
        switch self {
        case .initializationRequired: return "Initalisierung ..."
            //        case .clearingDatabase: return "Initalisierung wurde nicht erfolgreich abgeschlossen und muss wiederholt werden. Bereinige Unfalldatenbank, bitte warten ..."
            //        case .loadingData(let year): return "Konfiguriere Unfalldaten für das Jahr \(year) ... \n\nDas erfolgt nur einmalig beim allerersten Start der App für die Unfalljahre 2016 bis 2023 (in der Reihenfolge 2022, 2021, ..., 2016, 2023). \nDas dauert bis zu 10 Minuten oder länger. Bitte nicht abbrechen, sonst muss der Vorgang teilweise wiederholt werden.\nDie App kann in dieser Zeit schon  mit den ersten Daten benutzt werden."
        case .loadingData(let year): return "Lade Daten für \(year) von lokaler Datei ... "
        case .importingData(let year): return "Schreibe Daten von \(year) in die Datenbank... "
        case .initalized: return "... Initalisierung beendet"
        }
    }
}

struct AccidentCSVMapping: Hashable {
    let id: Int
    let jahr: Int
    let monat: Int
    let stunde: Int
    let wochentag: Int
    let unfallKategorie: Int
    let unfallArt: Int
    let unfallTyp1: Int
    let lichtVerhaeltnisse: Int
    let strassenZustand: Int
    let vehicleFlags: [VehicleMask: Int]
    let latitude: Int
    let longitude: Int

    let land: Int         // Spaltenindex für Bundesland
    let regbez: Int       // Spaltenindex für Regierungsbezirk
    let kreis: Int        // Spaltenindex für Kreis
    let gemeinde: Int     // Spaltenindex für Gemeinde
}

let mappingsByYear: [String: AccidentCSVMapping] = [
    "2016": AccidentCSVMapping(id: 1, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23, land: 2, regbez: 3, kreis: 4, gemeinde: 5),
    "2017": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 18, strassenZustand: 19, vehicleFlags: [.fahrrad: 13, .pkw: 14, .fussgaenger: 15, .krad: 16,                 .sonstige: 17 ], latitude: 23, longitude: 22, land: 2, regbez: 3, kreis: 4, gemeinde: 5),
    "2018": AccidentCSVMapping(id: 0, jahr: 5, monat: 6, stunde: 7, wochentag: 8, unfallKategorie:  9, unfallArt: 10, unfallTyp1: 11, lichtVerhaeltnisse: 12, strassenZustand: 19, vehicleFlags: [.fahrrad: 13, .pkw: 14, .fussgaenger: 15, .krad: 16, .gueterKfz: 17, .sonstige: 18 ], latitude: 23, longitude: 22, land: 1, regbez: 2, kreis: 3, gemeinde: 4),
    "2019": AccidentCSVMapping(id: 0, jahr: 5, monat: 6, stunde: 7, wochentag: 8, unfallKategorie:  9, unfallArt: 10, unfallTyp1: 11, lichtVerhaeltnisse: 12, strassenZustand: 23, vehicleFlags: [.fahrrad: 13, .pkw: 14, .fussgaenger: 15, .krad: 16, .gueterKfz: 17, .sonstige: 18 ], latitude: 22, longitude: 21, land: 1, regbez: 2, kreis: 3, gemeinde: 4),
    "2020": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 24, vehicleFlags: [.fahrrad: 14, .pkw: 15, .fussgaenger: 16, .krad: 17, .gueterKfz: 18, .sonstige: 19 ], latitude: 23, longitude: 22, land: 2, regbez: 3, kreis: 4, gemeinde: 5),
    "2021": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23, land: 2, regbez: 3, kreis: 4, gemeinde: 5),
    "2022": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23, land: 2, regbez: 3, kreis: 4, gemeinde: 5),
    "2023": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23, land: 2, regbez: 3, kreis: 4, gemeinde: 5)
]


/// Returns a dictionary with the records/lines that have to be read for each year.
/// Remark: The returned dictionary depends on the order of the years, but the result itself  is unordered, since it is just a dictionaray.
/// Example: "[\"2017\": 195229, \"2016\": 151673, \"2023\": 269048, \"2022\": 0, \"2020\": 0, \"2019\": 0, \"2018\": 73141, \"2021\": 0]
/// - Parameters:
///   - countOfAccidentsStored: Example: 1_823_882
///   - years: array of the years in the order as they are stored in the database, i.e. ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
/// - Returns: Example: "[\"2017\": 195229, \"2016\": 151673, \"2023\": 269048, \"2022\": 0, \"2020\": 0, \"2019\": 0, \"2018\": 73141, \"2021\": 0]
func linesToRead(countOfAccidentsStored: Int, years: [String]) -> [String: Int] {
    let countOfRecordsForYears: [String: Int] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]
    var countOfAccidentsStoredForRemainingYears = countOfAccidentsStored
    var linesToRead: [String: Int] = [:]
    for year in years {
        linesToRead[year] = countOfRecordsForYears[year]! - countOfAccidentsStoredForRemainingYears > 0 ? countOfRecordsForYears[year]! - countOfAccidentsStoredForRemainingYears : 0
        countOfAccidentsStoredForRemainingYears = max(countOfAccidentsStoredForRemainingYears - countOfRecordsForYears[year]!, 0)
    }
    return linesToRead
}



@MainActor
final class InitializationViewModel: ObservableObject {
    
    @Published var progress: Double? = 0.0
    @Published var initializationState: InitializationState
    
//    private var files: [String] = ["Unfallorte2016_LinRef.csv", "Unfallorte2017_LinRef.csv", "Unfallorte2018_LinRef.csv", "Unfallorte2019_LinRef.csv", "Unfallorte2020_LinRef.csv", "Unfallorte2021_LinRef.csv"]
//    private var viewContext = PersistenceController.shared.container.viewContext
//    private var backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    private var countOfAccidentsBy100000: Int = 0
    private var countOFAccidents: Int = 0
    private var countOfAccidentsInDatabase: Int = 0
    
    var isInitialized: Bool {
        return self.initializationState == .initalized
    }
    
    init() {
        
        print(" In Gesamtinitialisierung.")
        initializationState = .initializationRequired

        // Check number of records in database, if 1_823_882, then all data for 2016 to 2023 is contained in the database and all okay.
        do {
            let totalCountInDatabase = try  DatabaseService.shared.dbPool.read { db in
                try AccidentNeu.fetchCount(db)
            }
            print("ℹ️ Total number of accidents in database: \(totalCountInDatabase)")
            
            if totalCountInDatabase == ViewModel.totalCountinGermany { // 1_823_882
                // All good, database contains all datasets for all the years
                self.initializationState = .initalized
                print("No initialization required. Database is complete.")

            } else {

                self.initializationState = .initializationRequired
                print("Initialization required. Database is not complete.")
                Task.detached(priority: .high) {
                    try await self.loadDataIntoDatabaseGRDB()
                }
                print("Initialization ended.")
            }
        } catch {
            print("❌ Error initializing database: \(error)")
        }
    }

            
    /// Reads al files and stores the content in the database.
    nonisolated private func loadDataIntoDatabaseGRDB() async throws {
        
        let beginDateGRDB = Date.now
        
        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
//        let years = ["2016", "2022", "2021", "2020", "2019", "2018", "2017", "2023"]

//        let years = [ "2018", "2017"]
//        let years = [ "2018"]
//        let countOFRecordsForYears: [String: Int] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]

        for year in years {
            
            let progressCallback: @Sendable (Double) -> Void = { progress in
                DispatchQueue.main.async {
                    self.initializationState = .importingData(year: year)
                    self.progress = progress
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.initializationState = .loadingData(year: year)
                self?.progress = 0
            }
             
            if let fileURL = Bundle.main.url(forResource: "Unfallorte\(year)_LinRef", withExtension: "csv") {
                do {
                    let importer = AccidentImporter(dbPool: DatabaseService.shared.dbPool, mappings: mappingsByYear)
                    try await importer.importCSV2(for: year, from: fileURL, progressCallback: progressCallback)
                    print("✅ \(year) erfolgreich importiert")
                } catch {
                    print("❌ Fehler beim Importieren von \(year): \(error)")
                }
            } else {
                print("⚠️ Datei für Jahr \(year) nicht gefunden.")
            }
            
            print("year: \(year), duration: \(DateInterval(start: beginDateGRDB, end: Date.now).duration) s")
        }
        
        // Index creation afterwards
            do {
                let dbPool: DatabasePool = DatabaseService.shared.dbPool
                try await dbPool.write { db in
                    // Indexe anlegen.
                    try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_lon_lat ON accidents(longitude100, latitude100)")
//                    try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_unfallKategorie ON accidents(unfallKategorie)")
                }
                print("✅ Index erfolgreich erzeugt")
            } catch {
                print("❌ Fehler beim erzeugen von Index")
            }
        
        // Copy bundle version and build information into database
        DatabaseService.shared.writeBundleVersionToDB()
        
        DispatchQueue.main.async {
            self.initializationState = .initalized
        }

        print("Overall: \(years), duration: \(DateInterval(start: beginDateGRDB, end: Date.now).duration) s")
    }
}

// MARK: - CSV Import

struct AccidentImporter {
    let dbPool: DatabasePool
    let mappings: [String: AccidentCSVMapping]
    let fileManager = FileManager.default

    init(dbPool: DatabasePool, mappings: [String: AccidentCSVMapping]) {
        self.dbPool = dbPool
        self.mappings = mappings
    }


    
    func importCSV2(for year: String, from fileURL: URL, progressCallback: @escaping @Sendable (Double) -> Void) async throws {
        guard let mapping = mappings[year] else {
            throw NSError(domain: "Import", code: 1, userInfo: [NSLocalizedDescriptionKey: "Kein Mapping für Jahr \(year)"])
        }

        let lines = try await readLines(from: fileURL)
        let records = try lines.compactMap {
            try parseLine($0, with: mapping)
        }
//            .shuffled()  // randomise the order to get better geographical distribution on the map
        let total = records.count
        let chunkSize = 20_000
       
        try await dbPool.write { db in
            var processed = 0
            
            for chunk in records.chunked(into: chunkSize) {
                for var record in chunk {
                    try record.insert(db)
                }
                
                // Report progress via callback
                processed += chunk.count
                let progress = Double(processed) / Double(total)
                    progressCallback(progress)
            }
        }
    }
    

    private func readLines(from fileURL: URL) async throws -> [String] {
        let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        var lines = fileContent.components(separatedBy: .newlines)
        lines.removeAll { $0.isEmpty || $0.hasPrefix("#") }
        lines.removeFirst() // Skip header
        return lines
    }

    private func parseLine(_ line: String, with mapping: AccidentCSVMapping) throws -> AccidentNeu? {
        let components = line.components(separatedBy: ";")
        guard components.count > max(mapping.latitude, mapping.longitude) else { return nil }

        var mask: Int16 = 0
        for (type, index) in mapping.vehicleFlags {
            if components[index] == "1" {
                mask |= type.rawValue
            }
        }

        let lat = Double(components[mapping.latitude].replacingOccurrences(of: ",", with: "."))!
        let lon = Double(components[mapping.longitude].replacingOccurrences(of: ",", with: "."))!
        
        // The objectIds in the files count from 0 upwards line per line. The following creates a unique id for all files, using the year
        // e.g. for ojbectID = 1 in year 20216 it creates 2016_000_001. This is sufficient and still allows Int32 as data type.
        let year = Int32(components[mapping.jahr])!
//        let yearOffset = year % 2000                            // e.g. 2016 → 16
//        let objectID = Int32(components[mapping.id])!           // 1 ... number of lines in file
//        let uniqueID = Int32(yearOffset * 1_000_000 + objectID) // e.g. 16_000_001, counting up.
        
        return AccidentNeu(

//            id: uniqueID,
            id: nil,
            jahr: Int(year),
            monat: Int(components[mapping.monat])!,
            stunde: Int(components[mapping.stunde])!,
            wochentag: Int(components[mapping.wochentag])!,
            unfallKategorie: Int(components[mapping.unfallKategorie])!,
            unfallArt: Int(components[mapping.unfallArt])!,
            unfallTyp1: Int(components[mapping.unfallTyp1])!,
            lichtVerhaeltnisse: Int(components[mapping.lichtVerhaeltnisse])!,
            strassenZustand: Int(components[mapping.strassenZustand])!,
            vehicleMask: mask,
            latitude100: Int32(lat * 10_000_000),
            longitude100: Int32(lon * 10_000_000),
            
            land: Int(components[mapping.land])!,
            regbez: Int(components[mapping.regbez])!,
            kreis: Int(components[mapping.kreis])!,
            gemeinde: Int(components[mapping.gemeinde])!
        )
    }
}



private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

//    func deleteAllAccidentEntries() async {
//        DispatchQueue.main.async {
//            self.initializationState = .clearingDatabase
//        }
//        progress = nil
//
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Accident.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        backgroundContext.performAndWait { [unowned self] in
//            do {
//                try PersistenceController.shared.container.persistentStoreCoordinator.execute(deleteRequest, with: backgroundContext)
//            } catch let error {
//                print("Error deleting Accident entities : \(error).")
//            }
//        }
//    }

