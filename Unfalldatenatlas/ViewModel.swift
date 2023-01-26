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

class ViewModel: ObservableObject {
    @Published var annotations: [Unfall] = []
    
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
//                    print("Line: \(line.description)")
//                    print("Components: \(components)")
                    let objectID = Int(components[0])!
//                    if objectID % 10000 == 0 {
//                        print("ObjectID: \(objectID)")
//                    }
//                    print("ObjectID: \(objectID)")
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

        let urls = [URL.applicationSupportDirectory.appending(component: "Unfallorte_2016_LinRef.txt"),
                    URL.applicationSupportDirectory.appending(component: "Unfallorte2017_LinRef.txt"),
                    URL.applicationSupportDirectory.appending(component: "Unfallorte2018_LinRef.txt"),
                    URL.applicationSupportDirectory.appending(component: "Unfallorte2019_LinRef.txt"),
                    URL.applicationSupportDirectory.appending(component: "Unfallorte2020_LinRef.csv"),
                    URL.applicationSupportDirectory.appending(component: "Unfallorte2021_LinRef.csv")]
//        let url = URL.applicationSupportDirectory.appending(component: "Unfallorte2021_LinRef.csv")

        Task.init() {
            do {

                let readAndStoreData = false
                if readAndStoreData {
                    for url in urls {
                        print("Application Support Directory: \(url.description)")
                        print(url.description)
                        for try await line in url.lines.dropFirst() { // Skip first line which contains heaader information
                            
                            let components = line.components(separatedBy: ";") // split csv data of one line into its compontents (columns)
                            
                            // Create core data object of type Accident and fill with the data
                            let accident = Accident(context: PersistenceController.shared.container.viewContext)
                            accident.accidentObjectID = Int32(components[0].replacingOccurrences(of: ",", with: "."))!
                            accident.identStlae = components[1]
                            accident.land = Int16(components[2].replacingOccurrences(of: ",", with: "."))!
                            accident.regierungsBezirk = Int16(components[3].replacingOccurrences(of: ",", with: "."))!
                            accident.kreis = Int16(components[4].replacingOccurrences(of: ",", with: "."))!
                            accident.gemeinde = Int16(components[5].replacingOccurrences(of: ",", with: "."))!
                            accident.jahr = Int16(components[6].replacingOccurrences(of: ",", with: "."))!
                            accident.monat = Int16(components[7].replacingOccurrences(of: ",", with: "."))!
                            accident.stunde = Int16(components[8].replacingOccurrences(of: ",", with: "."))!
                            accident.wochentag = Int16(components[9].replacingOccurrences(of: ",", with: "."))!
                            accident.unfallKategorie = Int16(components[10].replacingOccurrences(of: ",", with: "."))!
                            accident.unfallArt = Int16(components[11].replacingOccurrences(of: ",", with: "."))!
                            accident.unfallTyp1 = Int16(components[12].replacingOccurrences(of: ",", with: "."))!
                            accident.lichtVerhaeltnisse = Int16(components[13].replacingOccurrences(of: ",", with: "."))!
                            accident.strassenZustand = Int16(components[14].replacingOccurrences(of: ",", with: "."))!
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
                        
//                        Col1=OBJECTID Long
//                        Col2=UIDENTSTLA Text Width 254
//                        Col3=ULAND Text Width 254
//                        Col4=UREGBEZ Text Width 254
//                        Col5=UKREIS Text Width 254
//                        Col6=UGEMEINDE Text Width 254
//                        Col7=UJAHR Text Width 254
//                        Col8=UMONAT Text Width 254
//                        Col9=USTUNDE Text Width 254
//                        Col10=UWOCHENTAG Text Width 254
//                        Col11=UKATEGORIE Text Width 254
                        
//                        Col12=UART Text Width 254
//                        Col13=UTYP1 Text Width 254
//                        Col14=IstRad Text Width 254
//                        Col15=IstPKW Text Width 254
//                        Col16=IstFuss Text Width 254
//                        Col17=IstKrad Text Width 254
//                        Col18=IstSonstig Text Width 254
//                        Col19=LICHT Text Width 3
//                        Col20=STRZUSTAND Text Width 3
//                        Col21=LINREFX Double
//                        Col22=LINREFY Double
//                        Col23=XGCSWGS84 Double
//                        Col24=YGCSWGS84 Double
                        
                        try PersistenceController.shared.container.viewContext.save()
                    }
                }
                
                // fetch count of accidents from database and print to console
                let countRequest = Accident.fetchRequest()
                let context = PersistenceController.shared.container.viewContext
                let totalCount =  try? context.count(for: countRequest)
                print ("Anzahl Unfälle in Datenbank: \(totalCount)")
                
                let request = Accident.fetchRequest()
                let longitudeMin = 9.11 - 0.08
                let longitudeMax = 9.11 + 0.08
                let lattitudeMin = 48.66 - 0.08
                let lattitudeMax = 48.66 + 0.08
                let predicate = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
//                let predicate = NSPredicate(format: "(longitude < %lf) AND (%lf < longitude) AND (lattitude < %lf) AND (%lf < lattitude)", argumentArray: [longitudeMin, longitudeMax, lattitudeMin, lattitudeMax])
                request.predicate = predicate
                let countResults = try? context.count(for: request)
                print ("Anzahl Unfälle im Geobereich ist \(countResults)")

                let accidents = try? context.fetch(request)
                print("\(accidents?.first?.debugDescription)")
                print("\(accidents?.last?.debugDescription)")
                
                if let accidents {
                    for accident in accidents {
                        print("Accident no \(accident.accidentObjectID): long = \(accident.longitude), lat = \(accident.lattitude), Datum: \(accident.jahr)-\(accident.monat), Tag: \(accident.wochentag)")
                    }
                }
                
            } catch {
                 print ("Error: \(error)")
            }
        }
        
    }
    
    static func specialFetchRequest() -> NSFetchRequest<Accident> {

        // Special fetch request around Steinenbronn (48.655059814453125 und long = 9.112565011959946)
        let request = Accident.fetchRequest()
        let longitudeMin = 9.11 - 0.08
        let longitudeMax = 9.11 + 0.08
        let lattitudeMin = 48.66 - 0.08
        let lattitudeMax = 48.66 + 0.08
        let predicate = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]

        request.predicate = predicate
        
        return request
    }
}
