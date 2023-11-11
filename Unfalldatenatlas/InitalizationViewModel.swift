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
// Jahr:                       2019       2020       2021       2022
// Unfälle mit Personenschaden 300_143    264_499    258_987    289_672
// Unfälle im Unfalldatenatlas 268_370,   237_994, " 233_208,   256_492
//
// Unfälle in der App insgesamt: 1_554_834
// Unfälle pro Jahr:
//   ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492]

import Foundation
import CoreData


enum InitializationState: Equatable {
    case initializationRequired
//    case clearingDatabase
    case loadingData(year: String)
    case initalized
    
    var text: String {
        switch self {
        case .initializationRequired: return "Initalisierung ..."
//        case .clearingDatabase: return "Initalisierung wurde nicht erfolgreich abgeschlossen und muss wiederholt werden. Bereinige Unfalldatenbank, bitte warten ..."
//        case .loadingData(let year): return "Konfiguriere Unfalldaten für das Jahr \(year) ... \n\nDas erfolgt nur einmalig beim allerersten Start der App für die Unfalljahre 2016 bis 2022 (in umgekehrter Reihenfolge). \nDas dauert bis zu 10 Minuten. Bitte nicht abbrechen, sonst muss der Vorgang wiederholt werden.\nDie App kann in dieser Zeit schon  mit den ersten Daten benutzt werden."
        case .loadingData(let year): return "Importiere Unfalldaten für das Jahr \(year) ... "
        case .initalized: return "... Initalisierung beendet"
        }
    }
}

class InitializationViewModel: ObservableObject {
    
    @Published var progress: Double? = 0.0
    @Published var initializationState: InitializationState
    
    private var files: [String] = ["Unfallorte2016_LinRef.csv", "Unfallorte2017_LinRef.csv", "Unfallorte2018_LinRef.csv", "Unfallorte2019_LinRef.csv", "Unfallorte2020_LinRef.csv", "Unfallorte2021_LinRef.csv"]
    private var viewContext = PersistenceController.shared.container.viewContext
    private var backgroundContext = PersistenceController.shared.container.newBackgroundContext()
    private var countOfAccidentsBy100000: Int = 0
    private var countOFAccidents: Int = 0
    private var countOfAccidentsInDatabase: Int = 0
    
    init() {
        
        print(" In Gesamtinitialisierung.")
        initializationState = .initializationRequired
        // Check lines in database, if 1_554_834, then all data for 2016 to 2022 is loaded.
        // Fetch count of accidents from database (overall and for the respective years) and print to console
        let countRequest = Accident.fetchRequest()
        let totalCount =  try? viewContext.count(for: countRequest)
        print("Initalisierung. Total Count ist: \(String(describing: totalCount))")

        //
        if let totalCount = totalCount, totalCount == ViewModel.countOfAllAccidents { // 1_554_834
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
        } else {
            DispatchQueue.main.async {
                self.initializationState = .initializationRequired
            }
            Task.init() {
                do {
                    countOfAccidentsInDatabase = totalCount ?? 0
                    try await loadDataIntoDatabase()
                } catch {
                    print("An errror occured during initialization.")
                }
            }
        }

        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    var isInitialized: Bool {
        return self.initializationState == .initalized
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
    
    
    /// Reads al files and stores the content in cord data. Uncomment relevant lines for respective files.
//    @MainActor 
    func loadDataIntoDatabase() async throws {

        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016"]
        let countOFRecordsForYear: [String: Double] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492]

        for year in years {
                    
        let countOfRecords = countOFRecordsForYear[year]!
            let url = Bundle.main.url(forResource: "Unfallorte\(year)_LinRef", withExtension: "csv")!
            
            print("Reading File: \(url.description) ...")
            
            DispatchQueue.main.async { [weak self] in
                self?.initializationState = .loadingData(year: year)
                self?.progress = 0
            }
            
            for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
                
                countOFAccidents += 1
                
                // Skip records that have already been read and stored in database
                if countOfAccidentsInDatabase < countOFAccidents {

                    countOfAccidentsBy100000 = countOFAccidents - (countOFAccidents % 100_000)
                    
                    let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
                    
                    backgroundContext.performAndWait { [unowned self] in
                        
                        let accident = Accident(context: backgroundContext)
                        fillObjectWithData(year: year, accident: accident, csvComponents: components)
                        accident.countOfAccidentsBy100000 = Int32(countOfAccidentsBy100000)
                        
                        //                print("Nr.: \(accident.accidentObjectID)")
                        
                        // Save context and update UI with info on progress every n recorda:
                        let currentObjectID = accident.accidentObjectID
                        if currentObjectID % 10_000 == 0 {
                            DispatchQueue.main.async { [weak self] in
                                self?.progress = Double(currentObjectID) / countOfRecords
                            }
                        }
                        // Save in chunks, only to have a progress bar that steps up repeatedly (and thus not stall for a while at 100%)
                        if currentObjectID % 20_000 == 0 {
                            try? backgroundContext.save()
                        }
                    }
                }
            }
        }
        
        backgroundContext.performAndWait {
            try? backgroundContext.save()
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
        }        
    }
   
    private func fillObjectWithData(year: String, accident: Accident, csvComponents: [String]) {
        
        switch year {
        case "2016":
            accident.accidentObjectID = Int32(csvComponents[1])!
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
        case "2021", "2022": // 2022 is of equal order (although one name in the csv file is different)
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

