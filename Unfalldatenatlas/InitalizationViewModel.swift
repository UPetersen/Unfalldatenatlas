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

import Foundation
import CoreData


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
        
        countOfAccidentsInDatabase = (try? viewContext.count(for: countRequest))!
        
        print("Initalisierung. Total Count ist: \(String(describing: totalCount))")
        
        //
        if let totalCount = totalCount, totalCount == ViewModel.countOfAllAccidents { // 1_823_882 (formerly 1_554_834)
            self.initializationState = .initalized
        } else {
            self.initializationState = .initializationRequired
            Task.detached(priority: .high) {
                do {
                    // WARNING:
                    // TODO: nur für das Testen auskommentiert.
                    //                                        countOfAccidentsInDatabase = totalCount ?? 0
                    
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
        
        // Provide one managed object at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Accident.entity(), managedObjectHandler: { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
            if let accident = managedObject as? Accident {
                let components = lines[index].components(separatedBy: ";") // split csv data of one line into its compontents (columns)
                self.fillObjectWithData(year: year, accident: accident, csvComponents: components)
                //                accident.countOfAccidentsBy100000 = accident.accidentObjectID % 10_000
            }
            index += 1
            
            if index % 10_000 == 0 {
                Task{ @MainActor [unowned self, index, total, year] in
                    self.initializationState = .importingData(year: year)
                    self.progress = Double(index) / Double(total)
                }
            }
            return false
        })
        return batchInsertRequest
    }
    
    
    nonisolated private func fillObjectWithData(year: String, accident: Accident, csvComponents: [String]) {
        
        switch year {
        case "2016":
            accident.accidentObjectID = Int32(csvComponents[1])! // Unterschied 2016
            accident.land = Int16(csvComponents[2])! // Unterschied 2018 und 2019
            //            accident.regierungsBezirk = Int16(csvComponents[3])!
            //            accident.kreis = Int16(csvComponents[4])!
            //            accident.gemeinde = Int16(csvComponents[5])!
            accident.jahr = Int16(csvComponents[6])!
            accident.monat = Int16(csvComponents[7])!
            accident.stunde = Int16(csvComponents[8])!
            accident.wochentag = Int16(csvComponents[9])!
            accident.unfallKategorie = Int16(csvComponents[10])!
            accident.unfallArt = Int16(csvComponents[11])!
            accident.unfallTyp1 = Int16(csvComponents[12])!
            accident.lichtVerhaeltnisse = Int16(csvComponents[13])!
            accident.strassenZustand = Int16(csvComponents[14])!
            accident.istFahrrad = csvComponents[15] == "1" ? true : false
            accident.istPkw = csvComponents[16] == "1" ? true : false
            accident.istFussgaenger = csvComponents[17] == "1" ? true : false
            accident.istKrad = csvComponents[18] == "1" ? true : false
            accident.istGueterKfz = csvComponents[19] == "1" ? true : false
            accident.istSonstige = csvComponents[20] == "1" ? true : false
            //            accident.lineRefX = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            //            accident.lineRefY = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[24].replacingOccurrences(of: ",", with: "."))!
        case "2017":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[2])!
            //            accident.regierungsBezirk = Int16(csvComponents[3])!
            //            accident.kreis = Int16(csvComponents[4])!
            //            accident.gemeinde = Int16(csvComponents[5])!
            accident.jahr = Int16(csvComponents[6])!
            accident.monat = Int16(csvComponents[7])!
            accident.stunde = Int16(csvComponents[8])!
            accident.wochentag = Int16(csvComponents[9])!
            accident.unfallKategorie = Int16(csvComponents[10])!
            accident.unfallArt = Int16(csvComponents[11])!
            accident.unfallTyp1 = Int16(csvComponents[12])!
            
            accident.istFahrrad = csvComponents[13] == "1" ? true : false
            accident.istPkw = csvComponents[14] == "1" ? true : false
            accident.istFussgaenger = csvComponents[15] == "1" ? true : false
            accident.istKrad = csvComponents[16] == "1" ? true : false
            
            // TODO: how to handle this property, when information is not present? Make optional?
            accident.istGueterKfz = false // Column not present in 2017 data -> denote as false
            accident.istSonstige = csvComponents[17] == "1" ? true : false
            
            accident.lichtVerhaeltnisse = Int16(csvComponents[18])!
            accident.strassenZustand = Int16(csvComponents[19])!
            
            //            accident.lineRefX = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            //            accident.lineRefY = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
        case "2018":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[1])!
            //            accident.regierungsBezirk = Int16(csvComponents[2])!
            //            accident.kreis = Int16(csvComponents[3])!
            //            accident.gemeinde = Int16(csvComponents[4])!
            accident.jahr = Int16(csvComponents[5])!
            accident.monat = Int16(csvComponents[6])!
            accident.stunde = Int16(csvComponents[7])!
            accident.wochentag = Int16(csvComponents[8])!
            accident.unfallKategorie = Int16(csvComponents[9])!
            accident.unfallArt = Int16(csvComponents[10])!
            accident.unfallTyp1 = Int16(csvComponents[11])!
            accident.lichtVerhaeltnisse = Int16(csvComponents[12])!
            
            accident.istFahrrad = csvComponents[13] == "1" ? true : false
            accident.istPkw = csvComponents[14] == "1" ? true : false
            accident.istFussgaenger = csvComponents[15] == "1" ? true : false
            accident.istKrad = csvComponents[16] == "1" ? true : false
            accident.istGueterKfz = csvComponents[17] == "1" ? true : false
            
            accident.istSonstige = csvComponents[18] == "1" ? true : false
            accident.strassenZustand = Int16(csvComponents[19])!
            //            accident.lineRefX = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            //            accident.lineRefY = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
        case "2019":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[1])!
            //            accident.regierungsBezirk = Int16(csvComponents[2])!
            //            accident.kreis = Int16(csvComponents[3])!
            //            accident.gemeinde = Int16(csvComponents[4])!
            accident.jahr = Int16(csvComponents[5])!
            accident.monat = Int16(csvComponents[6])!
            accident.stunde = Int16(csvComponents[7])!
            accident.wochentag = Int16(csvComponents[8])!
            accident.unfallKategorie = Int16(csvComponents[9])!
            accident.unfallArt = Int16(csvComponents[10])!
            accident.unfallTyp1 = Int16(csvComponents[11])!
            accident.lichtVerhaeltnisse = Int16(csvComponents[12])!
            
            accident.istFahrrad = csvComponents[13] == "1" ? true : false
            accident.istPkw = csvComponents[14] == "1" ? true : false
            accident.istFussgaenger = csvComponents[15] == "1" ? true : false
            accident.istKrad = csvComponents[16] == "1" ? true : false
            accident.istGueterKfz = csvComponents[17] == "1" ? true : false
            
            accident.istSonstige = csvComponents[18] == "1" ? true : false
            //            accident.lineRefX = Double(csvComponents[19].replacingOccurrences(of: ",", with: "."))!
            //            accident.lineRefY = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.strassenZustand = Int16(csvComponents[23])!
        case "2020":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[2])!
            //            accident.regierungsBezirk = Int16(csvComponents[3])!
            //            accident.kreis = Int16(csvComponents[4])!
            //            accident.gemeinde = Int16(csvComponents[5])!
            accident.jahr = Int16(csvComponents[6])!
            accident.monat = Int16(csvComponents[7])!
            accident.stunde = Int16(csvComponents[8])!
            accident.wochentag = Int16(csvComponents[9])!
            accident.unfallKategorie = Int16(csvComponents[10])!
            accident.unfallArt = Int16(csvComponents[11])!
            accident.unfallTyp1 = Int16(csvComponents[12])!
            accident.lichtVerhaeltnisse = Int16(csvComponents[13])!
            
            accident.istFahrrad = csvComponents[14] == "1" ? true : false
            accident.istPkw = csvComponents[15] == "1" ? true : false
            accident.istFussgaenger = csvComponents[16] == "1" ? true : false
            accident.istKrad = csvComponents[17] == "1" ? true : false
            accident.istGueterKfz = csvComponents[18] == "1" ? true : false
            accident.istSonstige = csvComponents[19] == "1" ? true : false
            //            accident.lineRefX = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            //            accident.lineRefY = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
            accident.strassenZustand = Int16(csvComponents[24])!
        case "2021", "2022", "2023":
            // 2022 is of equal order as 2021 (although one name in the csv file is different).
            // Same for 2023 (although it has one additional column at the end)accident.accidentObjectID = Int32(csvComponents[0])!
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[2])!
            //            accident.regierungsBezirk = Int16(csvComponents[3])!
            //            accident.kreis = Int16(csvComponents[4])!
            //            accident.gemeinde = Int16(csvComponents[5])!
            accident.jahr = Int16(csvComponents[6])!
            accident.monat = Int16(csvComponents[7])!
            accident.stunde = Int16(csvComponents[8])!
            accident.wochentag = Int16(csvComponents[9])!
            accident.unfallKategorie = Int16(csvComponents[10])!
            accident.unfallArt = Int16(csvComponents[11])!
            accident.unfallTyp1 = Int16(csvComponents[12])!
            accident.lichtVerhaeltnisse = Int16(csvComponents[13])!
            accident.strassenZustand = Int16(csvComponents[14])!
            accident.istFahrrad = csvComponents[15] == "1" ? true : false
            accident.istPkw = csvComponents[16] == "1" ? true : false
            accident.istFussgaenger = csvComponents[17] == "1" ? true : false
            accident.istKrad = csvComponents[18] == "1" ? true : false
            accident.istGueterKfz = csvComponents[19] == "1" ? true : false
            accident.istSonstige = csvComponents[20] == "1" ? true : false
            //            accident.lineRefX = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            //            accident.lineRefY = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[24].replacingOccurrences(of: ",", with: "."))!
        default:
            fatalError("Fatal error when storing csv data for accident to core data. Case does not exist.")
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

