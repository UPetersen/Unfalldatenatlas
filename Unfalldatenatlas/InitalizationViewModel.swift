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
//import GRDB

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
}

let mappingsByYear: [String: AccidentCSVMapping] = [
    "2016": AccidentCSVMapping(id: 1, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23),
    "2017": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 18, strassenZustand: 19, vehicleFlags: [.fahrrad: 13, .pkw: 14, .fussgaenger: 15, .krad: 16,                 .sonstige: 17 ], latitude: 23, longitude: 22),
    "2018": AccidentCSVMapping(id: 0, jahr: 5, monat: 6, stunde: 7, wochentag: 8, unfallKategorie:  9, unfallArt: 10, unfallTyp1: 11, lichtVerhaeltnisse: 12, strassenZustand: 19, vehicleFlags: [.fahrrad: 13, .pkw: 14, .fussgaenger: 15, .krad: 16, .gueterKfz: 17, .sonstige: 18 ], latitude: 23, longitude: 22),
    "2019": AccidentCSVMapping(id: 0, jahr: 5, monat: 6, stunde: 7, wochentag: 8, unfallKategorie:  9, unfallArt: 10, unfallTyp1: 11, lichtVerhaeltnisse: 12, strassenZustand: 23, vehicleFlags: [.fahrrad: 13, .pkw: 14, .fussgaenger: 15, .krad: 16, .gueterKfz: 17, .sonstige: 18 ], latitude: 22, longitude: 21),
    "2020": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 24, vehicleFlags: [.fahrrad: 14, .pkw: 15, .fussgaenger: 16, .krad: 17, .gueterKfz: 18, .sonstige: 19 ], latitude: 23, longitude: 22),
    "2021": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23),
    "2022": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23),
    "2023": AccidentCSVMapping(id: 0, jahr: 6, monat: 7, stunde: 8, wochentag: 9, unfallKategorie: 10, unfallArt: 11, unfallTyp1: 12, lichtVerhaeltnisse: 13, strassenZustand: 14, vehicleFlags: [.fahrrad: 15, .pkw: 16, .fussgaenger: 17, .krad: 18, .gueterKfz: 19, .sonstige: 20 ], latitude: 24, longitude: 23)
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
    
    private var files: [String] = ["Unfallorte2016_LinRef.csv", "Unfallorte2017_LinRef.csv", "Unfallorte2018_LinRef.csv", "Unfallorte2019_LinRef.csv", "Unfallorte2020_LinRef.csv", "Unfallorte2021_LinRef.csv"]
    private var viewContext = PersistenceController.shared.container.viewContext
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
        // Check lines in database, if 1_823_882 (formerly 1_554_834), then all data for 2016 to 2023 (formerly 2022) is loaded.
        // Fetch count of accidents from database (overall and for the respective years) and print to console
        let countRequest = Accident.fetchRequest()
        let totalCount =  try? viewContext.count(for: countRequest)
        
        countOfAccidentsInDatabase = totalCount!
        print("Initalisierung. Total Count ist: \(String(describing: totalCount))")
        
        //
        if let totalCount = totalCount, totalCount == ViewModel.countOfAllAccidents { // 1_823_882 (formerly 1_554_834)
            self.initializationState = .initalized
        } else {
            self.initializationState = .initializationRequired
            Task.detached(priority: .high) {
                do {
                    try await self.loadDataIntoDatabase()
                    
                } catch {
                    print("An errror occured during initialization.")
                }
            }
        }
    }
    
    
    /// Reads al files and stores the content in cord data. Uncomment relevant lines for respective files.
    nonisolated private func loadDataIntoDatabase() async throws {
        
        let beginDate = Date.now
        
        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
        //            let years = [ "2018", "2017"]
        let countOFRecordsForYears: [String: Int] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]
        
        let countOfAccidentsStored = await self.countOfAccidentsInDatabase
        let linesToRead = linesToRead(countOfAccidentsStored: countOfAccidentsStored, years: years)
        
        for year in years {
            
            guard linesToRead[year]! > 0 else { continue }
            
            var lines = [String()]
            lines.reserveCapacity(270_000)
            lines.removeFirst()
            let countOfRecordsForYear = countOFRecordsForYears[year]!
            let url = Bundle.main.url(forResource: "Unfallorte\(year)_LinRef", withExtension: "csv")!
            
            print("Reading File: \(url.description) ...")
            
            DispatchQueue.main.async { [weak self] in
                self?.initializationState = .loadingData(year: year)
                self?.progress = 0
            }
            
            // Async loop over the csv file for the respective year, reading only the lines necessary.
            // First line also has to be skipped, because it contains header data (i.e. names of the columens)
            for try await line in url.lines.dropFirst(1 + countOfRecordsForYear - linesToRead[year]!) {
                await MainActor.run{
                    self.countOFAccidents += 1
                }
                lines.append(line)
                if lines.count % 20_000 == 0 {
                    DispatchQueue.main.async { [unowned self, lines, countOfRecordsForYear] in
                        self.initializationState = .loadingData(year: year)
                        self.progress = Double(lines.count) / Double(countOfRecordsForYear)
                    }
                }
            }
            
            // Final import is needed for the remaining accidents (beyond the 20.000 units)
            try? await self.importAccidents(from: Array(lines), year: year)
            print("year: \(year), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s, \(countOfRecordsForYear) Records, \(lines.count) lines")
        }
        
        DispatchQueue.main.async {
            self.initializationState = .initalized
        }
        print("Overall: \(years), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s")
        
    }
    
    
    /// Uses `NSBatchInsertRequest` (BIR) to import accidents from a CSV file  into the Core Data store on a private queue.
    nonisolated private func importAccidents(from lines: [String], year: String) async throws {
        guard !lines.isEmpty else { return }
        
        let taskContext = PersistenceController.shared.container.newBackgroundContext()
        taskContext.automaticallyMergesChangesFromParent = false
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importAccidents"
        
        /// - Tag: performAndWait
        taskContext.performAndWait {
            
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.batchInsertRequest(with: lines, year: year)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            print("Failed to execute batch insert request.")
        }
        
        print("Successfully inserted data.")
        // Update UI State whenever a year is fully imported to initialized. If another year still needs to be imported, that year will then update the state as importing again
        DispatchQueue.main.async {
            self.initializationState = .initalized
        }
    }
    
    
    nonisolated private func batchInsertRequest(with lines: [String], year: String) -> NSBatchInsertRequest {
        var index = 0
        let total = lines.count
        
        // ❗️Mapping nur einmal am Anfang holen
        guard let mapping = mappingsByYear[year] else {
            fatalError("Kein Mapping für Jahr \(year)")
        }

        let batchInsertRequest = NSBatchInsertRequest(entity: Accident.entity()) { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
            
            if let accident = managedObject as? Accident {
                let components = lines[index].components(separatedBy: ";")
                self.fillObject(accident, with: components, using: mapping)
            }
            
            index += 1

            if index % 10_000 == 0 {
                Task { @MainActor [unowned self, index, total, year] in
                    self.initializationState = .importingData(year: year)
                    self.progress = Double(index) / Double(total)
                }
            }
            
            return false
        }
        
        return batchInsertRequest
    }
    
    nonisolated private func fillObject(_ accident: Accident, with csv: [String], using m: AccidentCSVMapping) {
        accident.accidentObjectID = Int32(csv[m.id])!
        accident.jahr = Int16(csv[m.jahr])!
        accident.monat = Int16(csv[m.monat])!
        accident.stunde = Int16(csv[m.stunde])!
        accident.wochentag = Int16(csv[m.wochentag])!
        accident.unfallKategorie = Int16(csv[m.unfallKategorie])!
        accident.unfallArt = Int16(csv[m.unfallArt])!
        accident.unfallTyp1 = Int16(csv[m.unfallTyp1])!
        accident.lichtVerhaeltnisse = Int16(csv[m.lichtVerhaeltnisse])!
        accident.strassenZustand = Int16(csv[m.strassenZustand])!

        var mask: Int16 = 0
        for (vehicleType, index) in m.vehicleFlags {
            if csv[index] == "1" {
                mask |= vehicleType.rawValue
            }
        }
        accident.vehicleMask = mask

        let lat = Double(csv[m.latitude].replacingOccurrences(of: ",", with: "."))!
        let lon = Double(csv[m.longitude].replacingOccurrences(of: ",", with: "."))!
        accident.setCoordinates(lat: lat, lon: lon)
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

