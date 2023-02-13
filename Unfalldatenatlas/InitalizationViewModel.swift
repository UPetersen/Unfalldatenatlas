//
//  InitalizationViewModel.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 05.02.23.
//

import Foundation
import CoreData


enum InitializationState: Equatable {
    case initializationRequired
    case clearingDatabase
    case loadingData(year: String)
    case storingData(year: String)
    case initalized
    
    var text: String {
        switch self {
        case .initializationRequired: return "Initalisierung ..."
        case .clearingDatabase: return "Bereinige Datenbank, bitte warten ..."
        case .loadingData(let year): return "Lade Unfalldaten für das Jahr \(year) ..."
        case .storingData(let year): return "Speichere Daten für das \(year) ..."
        case .initalized: return "... Initalisierung beendet"
        }
    }
}

class InitializationViewModel: ObservableObject {
    
    @Published var progress: Double? = 0.0
    @Published var initializationState: InitializationState
    
    private var files: [String] = ["Unfallorte2016_LinRef.csv", "Unfallorte2017_LinRef.csv", "Unfallorte2018_LinRef.csv", "Unfallorte2019_LinRef.csv", "Unfallorte2020_LinRef.csv", "Unfallorte2021_LinRef.csv"]
    private var context = PersistenceController.shared.container.viewContext
    
    init() {
        
        print(" In Gesamtinitialisierung.")
        initializationState = .initializationRequired
        // Check lines in database, if 1_298_342, then all data for 2016 t 2021 is loaded.
        // Fetch count of accidents from database (overall and for the respective years) and print to console
        let countRequest = Accident.fetchRequest()
        let totalCount =  try? context.count(for: countRequest)
        print("Initalisierung. Total Count ist: \(String(describing: totalCount))")

        // TODO: hier geht's weiter
        // Make view updates (initializationState) is updated on the main thread.
        if let totalCount = totalCount, totalCount == 1_298_342 {
            initializationState = .initalized
        } else {
            
            initializationState = .initializationRequired
            Task.init() {
                do {
                    deleteAllAccidentEntries()
                    try await loadDataIntoDatabase()
                } catch {
                    print("An errror occured during initialization.")
                }
            }
        }
        
    }
    
    func deleteAllAccidentEntries() {
        initializationState = .clearingDatabase
        progress = nil

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Accident.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try PersistenceController.shared.container.persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error {
            print("Error deleting Accident entities : \(error).")
        }
    }
    
    
    /// Reads al files and stores the content in cord data. Uncomment relevant lines for respective files.
    @MainActor func loadDataIntoDatabase() async throws {

        let context = PersistenceController.shared.container.newBackgroundContext()

        let years = ["2016", "2017", "2018", "2019", "2020", "2021"]
        let countOFRecordsForYear: [String: Double] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208 ]

        for year in years {

            let countOfRecords = countOFRecordsForYear[year]!
            let url = Bundle.main.url(forResource: "Unfallorte\(year)_LinRef", withExtension: "csv")!
            
            print("Reading File: \(url.description) ...")

            DispatchQueue.main.async { [weak self] in
                self?.initializationState = .loadingData(year: year)
                self?.progress = nil
            }

            for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
                
                let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
                let accident = Accident(context: context)
                fillObjectWithData(year: year, accident: accident, csvComponents: components)

//                print("Nr.: \(accident.accidentObjectID)")
                
                // Update UI with info on progress every 1000th record:
                if accident.accidentObjectID % 1000 == 0 {
                    DispatchQueue.main.async { [weak self] in
                        self?.progress = Double(accident.accidentObjectID) / countOfRecords
                    }
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.initializationState = .storingData(year: "year")
                self?.progress = nil
                print("In dispatch for saving context.")
            }
            try context.save()
            print("... done with file \(url.description).")

        }
        
        DispatchQueue.main.async {
            self.initializationState = .initalized
        }
    }
   
    private func fillObjectWithData(year: String, accident: Accident, csvComponents: [String]) {
        
        switch year {
        case "2016":
            accident.accidentObjectID = Int32(csvComponents[1])!
            accident.land = Int16(csvComponents[2])!
            accident.regierungsBezirk = Int16(csvComponents[3])!
            accident.kreis = Int16(csvComponents[4])!
            accident.gemeinde = Int16(csvComponents[5])!
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
            accident.lineRefX = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[24].replacingOccurrences(of: ",", with: "."))!
        case "2017":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[2])!
            accident.regierungsBezirk = Int16(csvComponents[3])!
            accident.kreis = Int16(csvComponents[4])!
            accident.gemeinde = Int16(csvComponents[5])!
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
            
            accident.lineRefX = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
        case "2018":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[1])!
            accident.regierungsBezirk = Int16(csvComponents[2])!
            accident.kreis = Int16(csvComponents[3])!
            accident.gemeinde = Int16(csvComponents[4])!
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
            accident.lineRefX = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
        case "2019":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[1])!
            accident.regierungsBezirk = Int16(csvComponents[2])!
            accident.kreis = Int16(csvComponents[3])!
            accident.gemeinde = Int16(csvComponents[4])!
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
            accident.lineRefX = Double(csvComponents[19].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.strassenZustand = Int16(csvComponents[23])!
        case "2020":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[2])!
            accident.regierungsBezirk = Int16(csvComponents[3])!
            accident.kreis = Int16(csvComponents[4])!
            accident.gemeinde = Int16(csvComponents[5])!
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
            
            accident.lineRefX = Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
            accident.strassenZustand = Int16(csvComponents[24])!
        case "2021":
            accident.accidentObjectID = Int32(csvComponents[0])!
            accident.land = Int16(csvComponents[2])!
            accident.regierungsBezirk = Int16(csvComponents[3])!
            accident.kreis = Int16(csvComponents[4])!
            accident.gemeinde = Int16(csvComponents[5])!
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
            accident.lineRefX = Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(csvComponents[24].replacingOccurrences(of: ",", with: "."))!
        default:
            fatalError("Fatal error when storing csv data for accident to core data. Case does not exist.")
        }
    }
    
}

