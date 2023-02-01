//
// ViewModel.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 18.01.23.
//

import Foundation
import Combine
import CoreLocation
import CoreData
import MapKit

// Number in line, name, sample data
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

// Steinenbronn: lat = 48.655059814453125 und long = 9.112565011959946

struct Unfall: Identifiable {
    var longitude: Double
    var latitude: Double
    var info: String
    var objectID: Int
    var id = UUID()
    var accidentID: String
    var uLand: Int
    
    var coordinate: CLLocationCoordinate2D {
      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct PredicatesForAccidentCharacteristics {
    var gemeinde: NSPredicate?
    var istFahrrad: NSPredicate?
    var istFussgaenger: NSPredicate?
    var istGueterKfz: NSPredicate?
    var istKrad: NSPredicate?
    var istPkw: NSPredicate?
    var istSonstige: NSPredicate?
    var jahr: NSPredicate?
    var kreis: NSPredicate?
    var land: NSPredicate?
//    var lattitude: NSPredicate?
    var lichtVerhaeltnisse: NSPredicate?
//    var lineRefX: NSPredicate?
//    var lineRefY: NSPredicate?
//    var longitude: NSPredicate?
    var monat: NSPredicate?
    var regierungsBezirk: NSPredicate?
    var strassenZustand: NSPredicate?
    var stunde: NSPredicate?
    var unfallArt: NSPredicate?
    var unfallKategorie: NSPredicate?
    var unfallTyp1: NSPredicate?
    var wochentag: NSPredicate?
    
    var predicates: [NSPredicate] {
        return [gemeinde, istFahrrad, istFussgaenger, istGueterKfz, istKrad, istPkw, istSonstige, jahr, kreis, land, lichtVerhaeltnisse, monat, regierungsBezirk, strassenZustand, stunde, unfallArt, unfallKategorie, unfallTyp1, wochentag].compactMap{$0}
    }
}



class ViewModel: ObservableObject {

    @Published var annotations: [Unfall] = []
    @Published var accidents: [Accident] = []
    @Published var countOfAllAccidents: Int = 0
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.6494018, longitude: 9.1091648), latitudinalMeters: 1000, longitudinalMeters: 1000)
    private let asyncContext = PersistenceController.shared.container.newBackgroundContext()
    
    var predicates = PredicatesForAccidentCharacteristics()
    
    init(initFromFile: Bool = false) {
//        self.annotations = annotations
    }
    
    
    //https://stackoverflow.com/questions/74318352/publishing-changes-from-background-threads-is-not-allowed-make-sure-to-publish
    
    @MainActor func fetchAccidents()  {
        
        let url = URL.applicationSupportDirectory.appending(component: "Unfallorte2021_LinRef.csv")
        print("Application Support Directory: \(url.description)")
        print(url.description)

        Task.init {
            do {
                var accidents: [Unfall] = []
                // Read each line of the data as it becomes available
                for try await line in url.lines.dropFirst().dropFirst(81000).prefix(3000) // Skip first line which contains heaader information
                {
                    // Do something with line.
                    let components = line.components(separatedBy: ";")
                    let objectID = Int(components[0])!
                    let UIDENTSTLAE = components[1]
                    let uLand = Int(components[2])!
                    let latitude = Double(components[24].replacingOccurrences(of: ",", with: "."))!
                    let longitude = Double(components[23].replacingOccurrences(of: ",", with: "."))!
                    if uLand == 8 {
                        accidents.append(Unfall(longitude: longitude, latitude: latitude, info: "hello", objectID: objectID, accidentID: UIDENTSTLAE, uLand: uLand))
                    }
                }
                annotations = accidents
            } catch {
                 print ("Error: \(error)")
            }
        }
    }
    
    @MainActor func importFromFiles() {


        Task.init() {
            do {

                let readAndStoreData = false
                if readAndStoreData {
                    try await ViewModel.readFromFileToCoreData()
                }
                
                // fetch count of accidents from database and print to console
                let countRequest = Accident.fetchRequest()
                let context = PersistenceController.shared.container.viewContext
                let totalCount =  try? context.count(for: countRequest)
                print ("Anzahl Unfälle in Datenbank: \(totalCount)")
                
                countRequest.predicate = NSPredicate(format: "%i == jahr", 2016)
                print ("Anzahl Unfälle in Datenbank für 2016: \(try? context.count(for: countRequest))")
                
                countRequest.predicate = NSPredicate(format: "%i == jahr", 2017)
                print ("Anzahl Unfälle in Datenbank für 2017: \(try? context.count(for: countRequest))")
                
                countRequest.predicate = NSPredicate(format: "%i == jahr", 2018)
                print ("Anzahl Unfälle in Datenbank für 2018: \(try? context.count(for: countRequest))")
                
                countRequest.predicate = NSPredicate(format: "%i == jahr", 2019)
                print ("Anzahl Unfälle in Datenbank für 2019: \(try? context.count(for: countRequest))")
                
                countRequest.predicate = NSPredicate(format: "%i == jahr", 2020)
                print ("Anzahl Unfälle in Datenbank für 2020: \(try? context.count(for: countRequest))")
                
                countRequest.predicate = NSPredicate(format: "%i == jahr", 2021)
                print ("Anzahl Unfälle in Datenbank für 2021: \(try? context.count(for: countRequest))")
                
                // Fetch some data to see if there is some correct data stored.
                let request = Accident.fetchRequest()
                let longitudeMin = 9.11 - 0.07
                let longitudeMax = 9.11 + 0.07
                let lattitudeMin = 48.66 - 0.07
                let lattitudeMax = 48.66 + 0.07
                let predicate = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
//                let predicate = NSPredicate(format: "(longitude < %lf) AND (%lf < longitude) AND (lattitude < %lf) AND (%lf < lattitude)", argumentArray: [longitudeMin, longitudeMax, lattitudeMin, lattitudeMax])
                request.predicate = predicate
                let countResults = try? context.count(for: request)
                print ("Anzahl Unfälle im Geobereich ist \(countResults)")

                // fetch some accidents to see if there is something in the database
                let accidents = try? context.fetch(request)
                print("\(accidents?.first?.debugDescription)")
                print("\(accidents?.last?.debugDescription)")
                
                // Print some accidents
//                if let accidents {
//                    for accident in accidents {
//                        print("Accident no \(accident.accidentObjectID): long = \(accident.longitude), lat = \(accident.lattitude), Datum: \(accident.jahr)-\(accident.monat), Tag: \(accident.wochentag)")
//                    }
//                }
                
            } catch {
                 print ("Error: \(error)")
            }
        }
        
    }
    
    func fetchTheAccidents(region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.66, longitude: 9.11), latitudinalMeters: 1000, longitudinalMeters: 1000)) {
        let longitudeMin = region.center.longitude - 0.5 * region.span.longitudeDelta
        let longitudeMax = region.center.longitude + 0.5 * region.span.longitudeDelta
        let lattitudeMin = region.center.latitude - 0.5 * region.span.latitudeDelta
        let lattitudeMax = region.center.latitude + 0.5 * region.span.latitudeDelta

        let predicateLongLat = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
        
//        predicates.istPkw = NSPredicate(format: "istPkw == 1")
//        predicates.istKrad = NSPredicate(format: "istKrad == 1")
        predicates.unfallKategorie = NSPredicate(format: "unfallKategorie <=2")
//        predicates.unfallArt = NSPredicate(format: "unfallArt <= 1")
//        predicates.unfallTyp1 = NSPredicate(format: "unfallTyp1 == 6")
        
        let request = Accident.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongLat] + predicates.predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]

        request.fetchLimit = 400
        request.fetchBatchSize = 50
        
        // Analyse
        let countAllAccidentsRequest = Accident.fetchRequest()
        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates.predicates)
        
        asyncContext.automaticallyMergesChangesFromParent = true
        asyncContext.perform { [unowned self] in
            do {
                let countOfAllAccidents = try asyncContext.count(for: countAllAccidentsRequest)
                let accidents =  try self.asyncContext.fetch(request)
                // self.accidents =  try self.asyncContext.fetch(request)
                DispatchQueue.main.async {
                    self.countOfAllAccidents = countOfAllAccidents
                    self.accidents = accidents
                }
            }
            catch {
                fatalError()
            }
        }
        
    }
    
//    static func specialFetchRequest() -> NSFetchRequest<Accident> {
//
//        // Special fetch request around Steinenbronn (48.655059814453125 und long = 9.112565011959946)
//        let request = Accident.fetchRequest()
//        let longitudeMin = 9.11 - 0.08
//        let longitudeMax = 9.11 + 0.08
//        let lattitudeMin = 48.66 - 0.08
//        let lattitudeMax = 48.66 + 0.08
//        let predicate = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf AND ", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
//
//        request.predicate = predicate
//
//        return request
//    }
    
    static func readFromFileToCoreData() async throws {

        // Each file has a different order of columns, that's why these are separate calls.
//        try await read2016Data(url: URL.applicationSupportDirectory.appending(component: "Unfallorte_2016_LinRef.csv"))
//        try await read2017Data(url: URL.applicationSupportDirectory.appending(component: "Unfallorte2017_LinRef.csv"))
//        try await read2018Data(url: URL.applicationSupportDirectory.appending(component: "Unfallorte2018_LinRef.csv"))
//        try await read2019Data(url: URL.applicationSupportDirectory.appending(component: "Unfallorte2019_LinRef.csv"))
//        try await read2020Data(url: URL.applicationSupportDirectory.appending(component: "Unfallorte2020_LinRef.csv"))
//        try await read2021Data(url: URL.applicationSupportDirectory.appending(component: "Unfallorte2021_LinRef.csv"))

    }
    
    static func read2016Data(url: URL) async throws {
        print("Reading File: \(url.description)")
        
        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
            
            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
            
            // Create core data object of type Accident and fill with the data
            let accident = Accident(context: PersistenceController.shared.container.viewContext)
            accident.identStlae = components[0]
            accident.accidentObjectID = Int32(components[1])!
            accident.land = Int16(components[2])!
            accident.regierungsBezirk = Int16(components[3])!
            accident.kreis = Int16(components[4])!
            accident.gemeinde = Int16(components[5])!
            accident.jahr = Int16(components[6])!
            accident.monat = Int16(components[7])!
            accident.stunde = Int16(components[8])!
            accident.wochentag = Int16(components[9])!
            accident.unfallKategorie = Int16(components[10])!
            accident.unfallArt = Int16(components[11])!
            accident.unfallTyp1 = Int16(components[12])!
            accident.lichtVerhaeltnisse = Int16(components[13])!
            accident.strassenZustand = Int16(components[14])!
            accident.istFahrrad = components[15] == "1" ? true : false
            accident.istPkw = components[16] == "1" ? true : false
            accident.istFussgaenger = components[17] == "1" ? true : false
            accident.istKrad = components[18] == "1" ? true : false
            accident.istGueterKfz = components[19] == "1" ? true : false
            accident.istSonstige = components[20] == "1" ? true : false
            accident.lineRefX = Double(components[21].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(components[22].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(components[23].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(components[24].replacingOccurrences(of: ",", with: "."))!
        }
        try PersistenceController.shared.container.viewContext.save()
        print("... done with file \(url.description).")
    }
    
    static func read2017Data(url: URL) async throws {
        print("Reading File: \(url.description)")
        
        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
            
            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
            
            // Create core data object of type Accident and fill with the data
            let accident = Accident(context: PersistenceController.shared.container.viewContext)

            accident.accidentObjectID = Int32(components[0])!
            accident.identStlae = components[1]
            accident.land = Int16(components[2])!
            accident.regierungsBezirk = Int16(components[3])!
            accident.kreis = Int16(components[4])!
            accident.gemeinde = Int16(components[5])!
            accident.jahr = Int16(components[6])!
            accident.monat = Int16(components[7])!
            accident.stunde = Int16(components[8])!
            accident.wochentag = Int16(components[9])!
            accident.unfallKategorie = Int16(components[10])!
            accident.unfallArt = Int16(components[11])!
            accident.unfallTyp1 = Int16(components[12])!
            

            accident.istFahrrad = components[13] == "1" ? true : false
            accident.istPkw = components[14] == "1" ? true : false
            accident.istFussgaenger = components[15] == "1" ? true : false
            accident.istKrad = components[16] == "1" ? true : false
            
            // TODO: how to handle this property, when information is not present? Make optional?
            accident.istGueterKfz = false // Column not present in 2017 data -> denote as false
            accident.istSonstige = components[17] == "1" ? true : false

            accident.lichtVerhaeltnisse = Int16(components[18])!
            accident.strassenZustand = Int16(components[19])!

            accident.lineRefX = Double(components[20].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(components[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(components[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(components[23].replacingOccurrences(of: ",", with: "."))!
        }
        try PersistenceController.shared.container.viewContext.save()
        print("... done with file \(url.description).")
    }
    
    static func read2018Data(url: URL) async throws {
        print("Reading File: \(url.description)")
        
        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
            
            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
            
            // Create core data object of type Accident and fill with the data
            let accident = Accident(context: PersistenceController.shared.container.viewContext)

            accident.accidentObjectID = Int32(components[0])!
            accident.identStlae = ""
            accident.land = Int16(components[1])!
            accident.regierungsBezirk = Int16(components[2])!
            accident.kreis = Int16(components[3])!
            accident.gemeinde = Int16(components[4])!
            accident.jahr = Int16(components[5])!
            accident.monat = Int16(components[6])!
            accident.stunde = Int16(components[7])!
            accident.wochentag = Int16(components[8])!
            accident.unfallKategorie = Int16(components[9])!
            accident.unfallArt = Int16(components[10])!
            accident.unfallTyp1 = Int16(components[11])!
            accident.lichtVerhaeltnisse = Int16(components[12])!

            accident.istFahrrad = components[13] == "1" ? true : false
            accident.istPkw = components[14] == "1" ? true : false
            accident.istFussgaenger = components[15] == "1" ? true : false
            accident.istKrad = components[16] == "1" ? true : false
            accident.istGueterKfz = components[17] == "1" ? true : false
            
            accident.istSonstige = components[18] == "1" ? true : false
            accident.strassenZustand = Int16(components[19])!
            accident.lineRefX = Double(components[20].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(components[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(components[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(components[23].replacingOccurrences(of: ",", with: "."))!
        }
        try PersistenceController.shared.container.viewContext.save()
        print("... done with file \(url.description).")
    }
    
    static func read2019Data(url: URL) async throws {
        print("Reading File: \(url.description)")
        
        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
            
            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
            
            // Create core data object of type Accident and fill with the data
            let accident = Accident(context: PersistenceController.shared.container.viewContext)

            accident.accidentObjectID = Int32(components[0])!
            accident.identStlae = ""
            accident.land = Int16(components[1])!
            accident.regierungsBezirk = Int16(components[2])!
            accident.kreis = Int16(components[3])!
            accident.gemeinde = Int16(components[4])!
            accident.jahr = Int16(components[5])!
            accident.monat = Int16(components[6])!
            accident.stunde = Int16(components[7])!
            accident.wochentag = Int16(components[8])!
            accident.unfallKategorie = Int16(components[9])!
            accident.unfallArt = Int16(components[10])!
            accident.unfallTyp1 = Int16(components[11])!
            accident.lichtVerhaeltnisse = Int16(components[12])!

            accident.istFahrrad = components[13] == "1" ? true : false
            accident.istPkw = components[14] == "1" ? true : false
            accident.istFussgaenger = components[15] == "1" ? true : false
            accident.istKrad = components[16] == "1" ? true : false
            accident.istGueterKfz = components[17] == "1" ? true : false
            
            accident.istSonstige = components[18] == "1" ? true : false
            accident.lineRefX = Double(components[19].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(components[20].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(components[21].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(components[22].replacingOccurrences(of: ",", with: "."))!
            accident.strassenZustand = Int16(components[23])!
        }
        try PersistenceController.shared.container.viewContext.save()
        print("... done with file \(url.description).")
    }
    
    static func read2020Data(url: URL) async throws {
        print("Reading File: \(url.description)")
        
        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
            
            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
            
            // Create core data object of type Accident and fill with the data
            let accident = Accident(context: PersistenceController.shared.container.viewContext)

            accident.accidentObjectID = Int32(components[0])!
            accident.identStlae = components[1]
            accident.land = Int16(components[2])!
            accident.regierungsBezirk = Int16(components[3])!
            accident.kreis = Int16(components[4])!
            accident.gemeinde = Int16(components[5])!
            accident.jahr = Int16(components[6])!
            accident.monat = Int16(components[7])!
            accident.stunde = Int16(components[8])!
            accident.wochentag = Int16(components[9])!
            accident.unfallKategorie = Int16(components[10])!
            accident.unfallArt = Int16(components[11])!
            accident.unfallTyp1 = Int16(components[12])!
            accident.lichtVerhaeltnisse = Int16(components[13])!

            accident.istFahrrad = components[14] == "1" ? true : false
            accident.istPkw = components[15] == "1" ? true : false
            accident.istFussgaenger = components[16] == "1" ? true : false
            accident.istKrad = components[17] == "1" ? true : false
            accident.istGueterKfz = components[18] == "1" ? true : false
            accident.istSonstige = components[19] == "1" ? true : false
            
            accident.lineRefX = Double(components[20].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(components[21].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(components[22].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(components[23].replacingOccurrences(of: ",", with: "."))!
            accident.strassenZustand = Int16(components[24])!
        }
        try PersistenceController.shared.container.viewContext.save()
        print("... done with file \(url.description).")
    }
    
    static func read2021Data(url: URL) async throws {
        print("Reading File: \(url.description)")
        
        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
            
            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
            
            // Create core data object of type Accident and fill with the data
            let accident = Accident(context: PersistenceController.shared.container.viewContext)
            accident.accidentObjectID = Int32(components[0])!
            accident.identStlae = components[1]
            accident.land = Int16(components[2])!
            accident.regierungsBezirk = Int16(components[3])!
            accident.kreis = Int16(components[4])!
            accident.gemeinde = Int16(components[5])!
            accident.jahr = Int16(components[6])!
            accident.monat = Int16(components[7])!
            accident.stunde = Int16(components[8])!
            accident.wochentag = Int16(components[9])!
            accident.unfallKategorie = Int16(components[10])!
            accident.unfallArt = Int16(components[11])!
            accident.unfallTyp1 = Int16(components[12])!
            accident.lichtVerhaeltnisse = Int16(components[13])!
            accident.strassenZustand = Int16(components[14])!
            accident.istFahrrad = components[15] == "1" ? true : false
            accident.istPkw = components[16] == "1" ? true : false
            accident.istFussgaenger = components[17] == "1" ? true : false
            accident.istKrad = components[18] == "1" ? true : false
            accident.istGueterKfz = components[19] == "1" ? true : false
            accident.istSonstige = components[20] == "1" ? true : false
            accident.lineRefX = Double(components[21].replacingOccurrences(of: ",", with: "."))!
            accident.lineRefY = Double(components[22].replacingOccurrences(of: ",", with: "."))!
            accident.longitude = Double(components[23].replacingOccurrences(of: ",", with: "."))!
            accident.lattitude = Double(components[24].replacingOccurrences(of: ",", with: "."))!
        }
        try PersistenceController.shared.container.viewContext.save()
        print("... done with file \(url.description).")
    }
    
}
