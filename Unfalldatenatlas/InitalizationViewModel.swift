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
    case initalized
    
    var text: String {
        switch self {
        case .initializationRequired: return "Initalisierung ..."
            //        case .clearingDatabase: return "Initalisierung wurde nicht erfolgreich abgeschlossen und muss wiederholt werden. Bereinige Unfalldatenbank, bitte warten ..."
            //        case .loadingData(let year): return "Konfiguriere Unfalldaten für das Jahr \(year) ... \n\nDas erfolgt nur einmalig beim allerersten Start der App für die Unfalljahre 2016 bis 2023 (in der Reihenfolge 2022, 2021, ..., 2016, 2023). \nDas dauert bis zu 10 Minuten oder länger. Bitte nicht abbrechen, sonst muss der Vorgang teilweise wiederholt werden.\nDie App kann in dieser Zeit schon  mit den ersten Daten benutzt werden."
        case .loadingData(let year): return "Importiere Unfalldaten für das Jahr \(year) ... "
        case .initalized: return "... Initalisierung beendet"
        }
    }
}

//@MainActor
final class InitializationViewModel: ObservableObject {
    
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
        // Check lines in database, if 1_823_882 (formerly 1_554_834), then all data for 2016 to 2023 (formerly 2022) is loaded.
        // Fetch count of accidents from database (overall and for the respective years) and print to console
        let countRequest = Accident.fetchRequest()
        let totalCount =  try? viewContext.count(for: countRequest)
        print("Initalisierung. Total Count ist: \(String(describing: totalCount))")
        
        //
        if let totalCount = totalCount, totalCount == ViewModel.countOfAllAccidents { // 1_823_882 (formerly 1_554_834)
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
        } else {
            DispatchQueue.main.async {
                self.initializationState = .initializationRequired
            }
            Task.init() {
                do {
                    // WARNING: / TODO: nur für das Testen auskommentiert.
//                    countOfAccidentsInDatabase = totalCount ?? 0
                    
//                    try await loadDataIntoDatabase()
//                    try await loadDataIntoDatabase2()
//                    try await loadDataIntoDatabase3()
                    try await loadDataIntoDatabase4()

                } catch {
                    print("An errror occured during initialization.")
                }
            }
        }
        
//        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //
//        // Observe Core Data remote change notifications on the queue where the changes were made.
//        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
//            print("Received a persistent store remote change notification.")
//            Task {
//                await self.fetchPersistentHistory()
//            }
//        }

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
        
        backgroundContext.automaticallyMergesChangesFromParent = true
//        backgroundContext.automaticallyMergesChangesFromParent = false

//        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
        let years = [ "2018", "2017"]

        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]

        let beginDate = Date.now

        for year in years {
            
            let countOfRecordsForYear = countOFRecordsForYears[year]!
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
//                        try? backgroundContext.save()
                        let currentObjectID = accident.accidentObjectID

                        // Update UI with progress bar
//                        if currentObjectID % 1_000 == 0 {
//                            DispatchQueue.main.async { [weak self] in
//                                self?.progress = Double(currentObjectID) / countOfRecordsForYear
//                            }
//                        }
                        
                        // Save in chunks, only to have a progress bar that steps up repeatedly (and thus not stall for a while at 100%)
                        if currentObjectID % 50_000 == 0 {
                            try? backgroundContext.save()
                        }
                    }
                }
            }
            print("year: \(year), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s, \(countOfRecordsForYear) Records")

        }
        
        backgroundContext.performAndWait {
            try? backgroundContext.save () //-> Slower than saving in chunks!, but final save needed, to save the remaining accidents
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
        }
        print("Overall: \(years), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s")
    }
    
    
    func loadDataIntoDatabase2() async throws {
        
        backgroundContext.automaticallyMergesChangesFromParent = false
        let beginDate = Date.now
        
//        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
        let years = [ "2018", "2017"]
        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]
//        let years = ["2022", "2021", "2016", "2023"]
//        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2021": 233_208, "2022": 256_492, "2023": 269_048]

        for year in years {
            
            var accidentPropertiesList = [AccidentProperties]()
            let countOfRecordsForYear = countOFRecordsForYears[year]!
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
                    
//                    backgroundContext.performAndWait { [unowned self] in
                        let accidentProperties = fillDictWithData(year: year, csvComponents: components)
                        accidentPropertiesList.append(accidentProperties)
//                        let accident = fillObjectWithData(year: year, csvComponents: components)
//                        accident.countOfAccidentsBy100000 = Int32(countOfAccidentsBy100000)
                        //                print("Nr.: \(accident.accidentObjectID)")
                        // Save context and update UI with info on progress every n recorda:
                        if accidentProperties.accidentObjectID % 10_000 == 0 {
                            DispatchQueue.main.async { [weak self] in
                                self?.progress = Double(accidentProperties.accidentObjectID) / countOfRecordsForYear
                            }
                        }
//                        // Save in chunks, only to have a progress bar that steps up repeatedly (and thus not stall for a while at 100%)
//                    if accidentProperties.accidentObjectID % 20_000 == 0 {
//                        try? await importAccidents(from: accidentPropertiesList)
//                        accidentPropertiesList = []
//                    }
                }
            }
            try? await importAccidents(from: accidentPropertiesList)
            print("year: \(year), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s, \(countOfRecordsForYear) Records")
        }
        
//        backgroundContext.performAndWait {
//            try? backgroundContext.save()
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
//        }
        
        print("Overall: \(years), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s")

    }
    
    func loadDataIntoDatabase3() async throws {
        
        backgroundContext.automaticallyMergesChangesFromParent = false
        let beginDate = Date.now
        
//        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
        let years = [ "2018", "2017"]
        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]
//        let years = ["2022", "2021", "2016", "2023"]
//        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2021": 233_208, "2022": 256_492, "2023": 269_048]

        for year in years {
            
            var accidents = [Accident]()
            let countOfRecordsForYear = countOFRecordsForYears[year]!
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
                    
//                    backgroundContext.performAndWait { [unowned self] in
                    
                    let accident = Accident(context: backgroundContext)
                    fillObjectWithData(year: year, accident: accident, csvComponents: components)
                    accident.countOfAccidentsBy100000 = Int32(countOfAccidentsBy100000)
                    accidents.append(accident)
                    
                        // Save context and update UI with info on progress every n recorda:
                        if accident.accidentObjectID % 10_000 == 0 {
                            DispatchQueue.main.async { [weak self] in
                                self?.progress = Double(accident.accidentObjectID) / countOfRecordsForYear
                            }
                        }
//                        // Save in chunks, only to have a progress bar that steps up repeatedly (and thus not stall for a while at 100%)
//                    if accident.accidentObjectID % 20_000 == 0 {
//                        try? await importAccidents2(from: accidents)
//                        accidents = []
//                    }
//                    }
                }
            }
            // Final import is needed for the remaining accidents (beyond the 20.000 units)
            try? await importAccidents2(from: accidents)
            print("year: \(year), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s, \(countOfRecordsForYear) Records")
        }
        
//        backgroundContext.performAndWait {
//            try? backgroundContext.save()
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
//        }
        
        print("Overall: \(years), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s")

    }
    

    func loadDataIntoDatabase4() async throws {
        
        backgroundContext.automaticallyMergesChangesFromParent = false
        let beginDate = Date.now
        
//        let years = ["2022", "2021", "2020", "2019", "2018", "2017", "2016", "2023"]
        let years = [ "2018", "2017"]
        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2017": 195_229, "2018": 211_868, "2019": 268_370, "2020": 237_994, "2021": 233_208, "2022": 256_492, "2023": 269_048]
        //        let years = ["2022", "2021", "2016", "2023"]
        //        let countOFRecordsForYears: [String: Double] = ["2016": 151_673, "2021": 233_208, "2022": 256_492, "2023": 269_048]
        
        for year in years {
            
//            Task.detached(priority: .high) {
                
//            }
            var lines = [String()]
            lines.reserveCapacity(260_000)
            lines.removeFirst()
            let countOfRecordsForYear = countOFRecordsForYears[year]!
            let url = Bundle.main.url(forResource: "Unfallorte\(year)_LinRef", withExtension: "csv")!
            
            print("Reading File: \(url.description) ...")
            
            DispatchQueue.main.async { [weak self] in
                self?.initializationState = .loadingData(year: year)
                self?.progress = 0
            }
            for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
                self.countOFAccidents += 1
                // Skip records that have already been read and stored in database
                if self.countOfAccidentsInDatabase < self.countOFAccidents {
                    
                    self.countOfAccidentsBy100000 = self.countOFAccidents - (self.countOFAccidents % 100_000)
                    lines.append(line)
                    
                    // Save context and update UI with info on progress every n recorda:
                    if self.countOFAccidents % 10_000 == 0 {
                        DispatchQueue.main.async { [unowned self] in
                            //                                self?.progress = Double(accident.accidentObjectID) / countOfRecordsForYear
                            self.progress = Double(self.countOFAccidents) / countOfRecordsForYear
                        }
                    }
                }
            }
            // Final import is needed for the remaining accidents (beyond the 20.000 units)
            //            try? await importAccidents4(from: Array(lines.dropFirst()), year: year)
                try? await self.importAccidents4(from: Array(lines), year: year)
            print("year: \(year), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s, \(countOfRecordsForYear) Records, \(lines.count) lines")
        }
//    }
            DispatchQueue.main.async {
                self.initializationState = .initalized
            }
        print("Overall: \(years), duration: \(DateInterval(start: beginDate, end: Date.now).duration) s")

    }
    

//    /// Fetches the earthquake feed from the remote server, and imports it into Core Data.
//    func fetchAccentsNeu() async throws {
//        let session = URLSession.shared
//        guard let (data, response) = try? await session.data(from: url),
//              let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200
//        else {
//            print("Failed to received valid response and/or data.")
//            throw QuakeError.missingData
//        }
//
//        do {
//            // Decode the GeoJSON into a data model.
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.dateDecodingStrategy = .secondsSince1970
//            let geoJSON = try jsonDecoder.decode(GeoJSON.self, from: data)
//            let quakePropertiesList = geoJSON.quakePropertiesList
//            print("Received \(quakePropertiesList.count) records.")
//
//            // Import the GeoJSON into Core Data.
//            print("Start importing data to the store...")
//            try await importQuakes(from: quakePropertiesList)
//            print("Finished importing data.")
//        } catch {
//            throw QuakeError.wrongDataFormat(error: error)
//        }
//    }

    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    private func importAccidents4(from lines: [String], year: String) async throws {
        guard !lines.isEmpty else { return }

//        let taskContext = newTaskContext()
        let taskContext = backgroundContext
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importQuakes"

        /// - Tag: performAndWait
        taskContext.performAndWait {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequestForLines(with: lines, year: year)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            print("Failed to execute batch insert request.")
        }

        print("Successfully inserted data.")
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    private func importAccidents2(from accidents: [Accident]) async throws {
        guard !accidents.isEmpty else { return }

//        let taskContext = newTaskContext()
        let taskContext = backgroundContext
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importQuakes"

        /// - Tag: performAndWait
        taskContext.performAndWait {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequestForAccidents(with: accidents)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            print("Failed to execute batch insert request.")
        }

        print("Successfully inserted data.")
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    private func importAccidents(from propertiesList: [AccidentProperties]) async throws {
        guard !propertiesList.isEmpty else { return }

//        let taskContext = newTaskContext()
        let taskContext = backgroundContext
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importQuakes"

        /// - Tag: performAndWait
        taskContext.performAndWait {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            print("Failed to execute batch insert request.")
        }

        print("Successfully inserted data.")
    }
    
    private func newBatchInsertRequestForLines(with lines: [String], year: String) -> NSBatchInsertRequest {
        var index = 0
        let total = lines.count
        
        // Provide one managed object at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Accident.entity(), managedObjectHandler: { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
//            print("The line: -------------------========================")
//            print(lines[0])
            if let accident = managedObject as? Accident {
                let components = lines[index].components(separatedBy: ";") // split csv data of one line into its compontents (columns)
                self.fillObjectWithData(year: year, accident: accident, csvComponents: components)
                accident.countOfAccidentsBy100000 = accident.accidentObjectID % 10_000
//                accident.countOfAccidentsBy100000 = Int32(countOfAccidentsBy100000)
            }
            index += 1
            return false
        })
        return batchInsertRequest
    }

    private func newBatchInsertRequestForAccidents(with accidents: [Accident]) -> NSBatchInsertRequest {
        var index = 0
        let total = accidents.count
        
        // Provide one managed object at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Accident.entity(), managedObjectHandler: { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
            if let accident = managedObject as? Accident {
                let data = accidents[index]
                accident.accidentObjectID = data.accidentObjectID
                accident.countOfAccidentsBy100000 = data.countOfAccidentsBy100000
                accident.istFahrrad = data.istFahrrad
                accident.istFussgaenger = data.istFussgaenger
                accident.istGueterKfz = data.istGueterKfz
                accident.istKrad = data.istKrad
                accident.istPkw = data.istPkw
                accident.istSonstige = data.istSonstige
                accident.jahr = data.jahr
                accident.land = data.land
                accident.lattitude = data.lattitude
                accident.lichtVerhaeltnisse = data.lichtVerhaeltnisse
                accident.longitude = data.longitude
                accident.monat = data.monat
                accident.strassenZustand = data.strassenZustand
                accident.stunde = data.stunde
                accident.unfallArt = data.unfallArt
                accident.unfallKategorie = data.unfallKategorie
                accident.unfallTyp1 = data.unfallTyp1
                accident.wochentag = data.wochentag
            }
            index += 1
            return false
        })
        return batchInsertRequest
    }

    private func newBatchInsertRequest(with propertyList: [AccidentProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
//            let batchInsertRequest = NSBatchInsertRequest(entity: Quake.entity(), dictionaryHandler: { dictionary in
            let batchInsertRequest = NSBatchInsertRequest(entity: Accident.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue)
            index += 1
            return false
        })
        return batchInsertRequest
    }


    private func fillDictWithData(year: String, csvComponents: [String]) -> AccidentProperties {
        switch year {
        case "2016":
            let accident = AccidentProperties(
                accidentObjectID: Int32(csvComponents[1])!, // Unterschied
                land: Int16(csvComponents[2])!,
                jahr: Int16(csvComponents[6])!,
                monat: Int16(csvComponents[7])!,
                stunde: Int16(csvComponents[8])!,
                wochentag: Int16(csvComponents[9])!,
                unfallKategorie: Int16(csvComponents[10])!,
                unfallArt: Int16(csvComponents[11])!,
                unfallTyp1: Int16(csvComponents[12])!,
                lichtVerhaeltnisse: Int16(csvComponents[13])!,
                strassenZustand: Int16(csvComponents[14])!,
                istFahrrad: csvComponents[15] == "1" ? true : false,
                istPkw: csvComponents[16] == "1" ? true : false,
                istFussgaenger: csvComponents[17] == "1" ? true : false,
                istKrad: csvComponents[18] == "1" ? true : false,
                istGueterKfz: csvComponents[19] == "1" ? true : false,
                istSonstige: csvComponents[20] == "1" ? true : false,
                longitude: Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!,
                lattitude: Double(csvComponents[24].replacingOccurrences(of: ",", with: "."))!,
                countOfAccidentsBy100000: Int32(csvComponents[1])! % 100_000
            )
            //            accident.regierungsBezirk = Int16(csvComponents[3])!
            //            accident.kreis = Int16(csvComponents[4])!
            //            accident.gemeinde = Int16(csvComponents[5])!
            return accident
            
        case "2017":
            let accident = AccidentProperties(
                accidentObjectID: Int32(csvComponents[0])!,
                land: Int16(csvComponents[2])!,
            //            regierungsBezirk = Int16(csvComponents[3])!
            //            kreis = Int16(csvComponents[4])!
            //            gemeinde = Int16(csvComponents[5])!
                jahr: Int16(csvComponents[6])!,
                monat: Int16(csvComponents[7])!,
                stunde: Int16(csvComponents[8])!,
                wochentag: Int16(csvComponents[9])!,
                unfallKategorie: Int16(csvComponents[10])!,
                unfallArt: Int16(csvComponents[11])!,
                unfallTyp1: Int16(csvComponents[12])!,

                lichtVerhaeltnisse: Int16(csvComponents[18])!,
            
                strassenZustand: Int16(csvComponents[19])!,

                istFahrrad: csvComponents[13] == "1" ? true : false,
                istPkw: csvComponents[14] == "1" ? true : false,
                istFussgaenger: csvComponents[15] == "1" ? true : false,
                istKrad: csvComponents[16] == "1" ? true : false,
            
            // TODO: how to handle this property, when information is not present? Make optional?
                istGueterKfz: false, // Column not present in 2017 data -> denote as false
                istSonstige: csvComponents[17] == "1" ? true : false,
            
                longitude: Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!,
                lattitude: Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!,
                countOfAccidentsBy100000: Int32(csvComponents[0])! % 100_000
            )
            return accident
            
        case "2018":
            let accident = AccidentProperties(
                accidentObjectID: Int32(csvComponents[0])!,
                land: Int16(csvComponents[1])!,
            //            regierungsBezirk = Int16(csvComponents[2])!
            //            kreis = Int16(csvComponents[3])!
            //            gemeinde = Int16(csvComponents[4])!
                jahr: Int16(csvComponents[5])!,
                monat: Int16(csvComponents[6])!,
                stunde: Int16(csvComponents[7])!,
                wochentag: Int16(csvComponents[8])!,
                unfallKategorie: Int16(csvComponents[9])!,
                unfallArt: Int16(csvComponents[10])!,
                unfallTyp1: Int16(csvComponents[11])!,
                lichtVerhaeltnisse: Int16(csvComponents[12])!,
            
                strassenZustand: Int16(csvComponents[19])!,

                istFahrrad: csvComponents[13] == "1" ? true : false,
                istPkw: csvComponents[14] == "1" ? true : false,
                istFussgaenger: csvComponents[15] == "1" ? true : false,
                istKrad: csvComponents[16] == "1" ? true : false,
                istGueterKfz: csvComponents[17] == "1" ? true : false,
            
                istSonstige: csvComponents[18] == "1" ? true : false,
                longitude: Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!,
                lattitude: Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!,
                countOfAccidentsBy100000: Int32(csvComponents[0])! % 100_000
                )
            return accident
            
        case "2019":
            let accident = AccidentProperties(
                accidentObjectID: Int32(csvComponents[0])!,
                land: Int16(csvComponents[1])!,
                //            regierungsBezirk: Int16(csvComponents[2])!
                //            kreis: Int16(csvComponents[3])!
                //            gemeinde: Int16(csvComponents[4])!
                jahr: Int16(csvComponents[5])!,
                monat: Int16(csvComponents[6])!,
                stunde: Int16(csvComponents[7])!,
                wochentag: Int16(csvComponents[8])!,
                unfallKategorie: Int16(csvComponents[9])!,
                unfallArt: Int16(csvComponents[10])!,
                unfallTyp1: Int16(csvComponents[11])!,
                lichtVerhaeltnisse: Int16(csvComponents[12])!,
                
                strassenZustand: Int16(csvComponents[23])!,
                
                istFahrrad: csvComponents[13] == "1" ? true : false,
                istPkw: csvComponents[14] == "1" ? true : false,
                istFussgaenger: csvComponents[15] == "1" ? true : false,
                istKrad: csvComponents[16] == "1" ? true : false,
                istGueterKfz: csvComponents[17] == "1" ? true : false,
                
                istSonstige: csvComponents[18] == "1" ? true : false,
                //            lineRefX: Double(csvComponents[19].replacingOccurrences(of: ",", with: "."))!
                //            lineRefY: Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
                longitude: Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!,
                lattitude: Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!,
                countOfAccidentsBy100000: Int32(csvComponents[0])! % 100_000
            )
            return accident
            
        case "2020":
            let accident = AccidentProperties(
                accidentObjectID: Int32(csvComponents[0])!,
                land: Int16(csvComponents[2])!,
                //            regierungsBezirk: Int16(csvComponents[3])!
                //            kreis: Int16(csvComponents[4])!
                //            gemeinde: Int16(csvComponents[5])!
                jahr: Int16(csvComponents[6])!,
                monat: Int16(csvComponents[7])!,
                stunde: Int16(csvComponents[8])!,
                wochentag: Int16(csvComponents[9])!,
                unfallKategorie: Int16(csvComponents[10])!,
                unfallArt: Int16(csvComponents[11])!,
                unfallTyp1: Int16(csvComponents[12])!,
                lichtVerhaeltnisse: Int16(csvComponents[13])!,
                
                strassenZustand: Int16(csvComponents[24])!,
                
                istFahrrad: csvComponents[14] == "1" ? true : false,
                istPkw: csvComponents[15] == "1" ? true : false,
                istFussgaenger: csvComponents[16] == "1" ? true : false,
                istKrad: csvComponents[17] == "1" ? true : false,
                istGueterKfz: csvComponents[18] == "1" ? true : false,
                istSonstige: csvComponents[19] == "1" ? true : false,
                //            lineRefX: Double(csvComponents[20].replacingOccurrences(of: ",", with: "."))!
                //            lineRefY: Double(csvComponents[21].replacingOccurrences(of: ",", with: "."))!
                longitude: Double(csvComponents[22].replacingOccurrences(of: ",", with: "."))!,
                lattitude: Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!,
                countOfAccidentsBy100000: Int32(csvComponents[0])! % 100_000
            )
            return accident


        case "2021", "2022", "2023":
            let accident = AccidentProperties(
                accidentObjectID: Int32(csvComponents[0])!, // Unterschied
                land: Int16(csvComponents[2])!,
                jahr: Int16(csvComponents[6])!,
                monat: Int16(csvComponents[7])!,
                stunde: Int16(csvComponents[8])!,
                wochentag: Int16(csvComponents[9])!,
                unfallKategorie: Int16(csvComponents[10])!,
                unfallArt: Int16(csvComponents[11])!,
                unfallTyp1: Int16(csvComponents[12])!,
                lichtVerhaeltnisse: Int16(csvComponents[13])!,
                strassenZustand: Int16(csvComponents[14])!,
                istFahrrad: csvComponents[15] == "1" ? true : false,
                istPkw: csvComponents[16] == "1" ? true : false,
                istFussgaenger: csvComponents[17] == "1" ? true : false,
                istKrad: csvComponents[18] == "1" ? true : false,
                istGueterKfz: csvComponents[19] == "1" ? true : false,
                istSonstige: csvComponents[20] == "1" ? true : false,
                longitude: Double(csvComponents[23].replacingOccurrences(of: ",", with: "."))!,
                lattitude: Double(csvComponents[24].replacingOccurrences(of: ",", with: "."))!,
                countOfAccidentsBy100000: Int32(csvComponents[0])! % 100_000
            )
            return accident

        default:
            fatalError("Fatal error when storing csv data for accident to core data. Case does not exist.")
        }
    }
    private func fillObjectWithData(year: String, accident: Accident, csvComponents: [String]) {
        
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

/// A struct encapsulating the properties of a Quake.
struct AccidentProperties {
    
    let accidentObjectID: Int32
    let land: Int16
    let jahr: Int16
    let monat: Int16
    let stunde: Int16
    let wochentag: Int16
    let unfallKategorie: Int16
    let unfallArt: Int16
    let unfallTyp1: Int16
    let lichtVerhaeltnisse: Int16
    let strassenZustand: Int16
    let istFahrrad: Bool
    let istPkw: Bool
    let istFussgaenger: Bool
    let istKrad: Bool
    let istGueterKfz: Bool
    let istSonstige: Bool
    let longitude: Double
    let lattitude: Double
    let countOfAccidentsBy100000: Int32

        
    // The keys must have the same name as the attributes of the Quake entity.
    var dictionaryValue: [String: Any] {
        [
            "accidentObjectID": accidentObjectID,
            "land": land,
            "jahr": jahr,
            "monat": monat,
            "stunde": stunde,
            "wochentag": wochentag,
            "unfallKategorie": unfallKategorie,
            "unfallArt": unfallArt,
            "unfallTyp1": unfallTyp1,
            "lichtVerhaeltnisse": lichtVerhaeltnisse,
            "strassenZustand": strassenZustand,
            "istFahrrad": istFahrrad,
            "istPkw": istPkw,
            "istFussgaenger": istFussgaenger,
            "istKrad": istKrad,
            "istGueterKfz": istGueterKfz,
            "istSonstige": istSonstige,
            "longitude": longitude,
            "lattitude": lattitude,
            "countOfAccidentsBy100000": countOfAccidentsBy100000
        ]
    }
}



enum QuakeError: Error {
    case wrongDataFormat(error: any Error)
    case missingData
    case creationError
    case batchInsertError
    case batchDeleteError
    case persistentHistoryChangeError
    case unexpectedError(error: any Error)
}

extension QuakeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .wrongDataFormat(let error):
            return NSLocalizedString("Could not digest the fetched data. \(error.localizedDescription)", comment: "")
        case .missingData:
            return NSLocalizedString("Found and will discard a quake missing a valid code, magnitude, place, or time.", comment: "")
        case .creationError:
            return NSLocalizedString("Failed to create a new Quake object.", comment: "")
        case .batchInsertError:
            return NSLocalizedString("Failed to execute a batch insert request.", comment: "")
        case .batchDeleteError:
            return NSLocalizedString("Failed to execute a batch delete request.", comment: "")
        case .persistentHistoryChangeError:
            return NSLocalizedString("Failed to execute a persistent history change request.", comment: "")
        case .unexpectedError(let error):
            return NSLocalizedString("Received unexpected error. \(error.localizedDescription)", comment: "")
        }
    }
}

extension QuakeError: Identifiable {
    var id: String? {
        errorDescription
    }
}


