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

//struct Unfall: Identifiable {
//    var longitude: Double
//    var latitude: Double
//    var info: String
//    var objectID: Int
//    var id = UUID()
//    var accidentID: String
//    var uLand: Int
//
//    var coordinate: CLLocationCoordinate2D {
//      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//}
//
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
    var lichtVerhaeltnisse: NSPredicate?
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

struct AccidentDataFilter {
//    var gemeinde: NSPredicate?
    var istFahrrad = IstFahrrad.keineAuswahl
    var istFussgaenger = IstFussgaenger.keineAuswahl
    var istGueterKfz = IstGueterKfz.keineAuswahl
    var istKrad = IstKrad.keineAuswahl
    var istPkw = IstPkw.keineAuswahl
    var istSonstige = IstSonstige.keineAuswahl
    var jahr = UnfallJahr.keineAuswahl
//    var kreis: NSPredicate?
    var land = Land.keineAuswahl
    var lichtVerhaeltnisse = LichtVerhaeltnisse.keineAuswahl
    var monat = UnfallMonat.keineAuswahl
//    var regierungsBezirk: NSPredicate?
    var strassenZustand = StrassenZustand.keineAuswahl
//    var stunde: NSPredicate?
    var unfallArt = UnfallArt.keineAuswahl
    var unfallKategorie = UnfallKategorie.keineAuswahl
    var unfallTyp1 = UnfallTyp1.keineAuswahl
    var wochentag = UnfallWochentag.keineAuswahl
    
    var predicates: [NSPredicate] {
//        return [gemeinde, istFahrrad, istFussgaenger, istGueterKfz, istKrad, istPkw, istSonstige, jahr, kreis, land, lichtVerhaeltnisse, monat, regierungsBezirk, strassenZustand, stunde, unfallArt, unfallKategorie, unfallTyp1, wochentag].compactMap{$0}
        return [istFahrrad.predicate,
                istFussgaenger.predicate,
                istGueterKfz.predicate,
                istKrad.predicate,
                istPkw.predicate,
                istSonstige.predicate,
                unfallArt.predicate,
                unfallKategorie.predicate,
                unfallTyp1.predicate,
                lichtVerhaeltnisse.predicate,
                strassenZustand.predicate,
                jahr.predicate,
                monat.predicate,
                wochentag.predicate,
                land.predicate
        ].compactMap{$0}
    }
}



class ViewModel: ObservableObject {

    @Published var accidents: [Accident] = []
    @Published var countOfAllAccidents: Int = 0
    @Published var region: MKCoordinateRegion = MKCoordinateRegion() //center: CLLocationCoordinate2D(latitude: 48.6494018, longitude: 9.1091648), latitudinalMeters: 1000, longitudinalMeters: 1000)
    @Published var predicates = PredicatesForAccidentCharacteristics()
    @Published var accidentDataFilters = AccidentDataFilter()
    
    let locationManager: LocationManager = LocationManager()
    
    private let asyncContext = PersistenceController.shared.container.newBackgroundContext()
    private let maxCountOfAccidents = 300 // Maximum number of accidents to fetched -> fetchLimit for fetch request.
    private let batchSize = 50            // Batch size for fetch request
    
    init(initFromFile: Bool = false) {
//        self.annotations = annotations
    }
    
    

    /// Deletes all accidents and refetches them to display the icons with each accident instantly. Otherwhise reused annotations will not update, but only new ones. I.e. icons for each accident were only toggled, whenn a new accident was panned into the visible area.
    func refetchAccidents() {
        self.accidents = []
        let region = self.region
        self.fetchTheAccidents(region: region)
    }
    
    /// Loads accidents for the current region from the database.
    func fetchTheAccidents() {
        let region = self.region
        self.fetchTheAccidents(region: region)
//
//        let longitudeMin = region.center.longitude - 0.5 * region.span.longitudeDelta
//        let longitudeMax = region.center.longitude + 0.5 * region.span.longitudeDelta
//        let lattitudeMin = region.center.latitude - 0.5 * region.span.latitudeDelta
//        let lattitudeMax = region.center.latitude + 0.5 * region.span.latitudeDelta
//
//        let predicateLongLat = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
//
//        let request = Accident.fetchRequest()
////        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongLat] + predicates.predicates)
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongLat] + accidentDataFilters.predicates)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
//
//        request.fetchLimit = 500
//        request.fetchBatchSize = 50
//
//        print("Das Predicate des Fetch Request: \(request.predicate!.debugDescription)")
//
//        // Analyse
//        let countAllAccidentsRequest = Accident.fetchRequest()
////        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates.predicates)
//        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)
//
//        asyncContext.automaticallyMergesChangesFromParent = true
////        asyncContext.reset()
//        asyncContext.perform { [unowned self] in
//            do {
//                let countOfAllAccidents = try asyncContext.count(for: countAllAccidentsRequest)
//                let accidents =  try self.asyncContext.fetch(request)
//                // self.accidents =  try self.asyncContext.fetch(request)
//                DispatchQueue.main.async {
//                    self.countOfAllAccidents = countOfAllAccidents
//                    self.accidents = accidents
//                }
//            }
//            catch {
//                fatalError()
//            }
//        }
    }

    /// Loads accidents for the region from the database.
    func fetchTheAccidents(region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.66, longitude: 9.11), latitudinalMeters: 1000, longitudinalMeters: 1000)) {
        
        let longitudeMin = region.center.longitude - 0.5 * region.span.longitudeDelta
        let longitudeMax = region.center.longitude + 0.5 * region.span.longitudeDelta
        let lattitudeMin = region.center.latitude - 0.5 * region.span.latitudeDelta
        let lattitudeMax = region.center.latitude + 0.5 * region.span.latitudeDelta

        let predicateLongLat = NSPredicate(format: "%lf < longitude AND longitude < %lf AND %lf < lattitude AND lattitude < %lf", longitudeMin, longitudeMax, lattitudeMin, lattitudeMax)
        
        let request = Accident.fetchRequest()
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongLat] + predicates.predicates)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLongLat] + accidentDataFilters.predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]

        request.fetchLimit = maxCountOfAccidents
        request.fetchBatchSize = batchSize
        
        print("Das Predicate des Fetch Request: \(request.predicate!.debugDescription)")
        
        // Analyse
        let countAllAccidentsRequest = Accident.fetchRequest()
//        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates.predicates)
        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)

        asyncContext.automaticallyMergesChangesFromParent = true
//        asyncContext.reset()
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
    
    
    
}
