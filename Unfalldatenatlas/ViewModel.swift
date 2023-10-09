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


struct AccidentDataFilter: Equatable {
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
    
    static let countOfAllAccidents = 1_554_834 // To be filled in by hand, whenever new data files for new years are added.

    @Published var accidents: [Accident] = [] // needs to be a publisher due to showSymbols in content view, but this gives a Zirkelbezug?
    @Published var countOfAccidentsInRegion: Int = 0
    @Published var countOfSelectedAccidents: Int = 0
    @Published var isFetchingAccidents = false
    @Published var accidentDataFilters = AccidentDataFilter()
            
    private let asyncContext = PersistenceController.shared.container.newBackgroundContext()
    private (set) var fetchLimit = 400 //300 // Maximum number of accidents to fetched -> fetchLimit for fetch request.
    
    init(initFromFile: Bool = false) {
        asyncContext.automaticallyMergesChangesFromParent = true
        
        #if DEBUG
            print("Running in debug mode.")
        #else
            print("Running in release mode.")
        #endif
    }
    

    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
    func fetchAccidentsAsync(region: MKCoordinateRegion) async {
        if Task.isCancelled {
            print("------Task is cancelled 0 ----------")
            return
        }
        Task() {
            fetchAccidents(region: region)
        }
    }

    /// Loads the count of selected accidents from the database.
    ///
    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region.
    func fetchCountOfSelectedAccidents() async {
        
        if Task.isCancelled {
            print("------Task fetchCountOfSelectedAccidents is cancelled 0 ----------")
            return
        }

        asyncContext.performAndWait { [unowned self] in
            do {
                if Task.isCancelled {
                    print("------Task fetchCountOfSelectedAccidents is cancelled 1 ----------")
                    return
                }
                let countAllAccidentsRequest = Accident.fetchRequest()
                countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)

                if Task.isCancelled {
                    print("------Task fetchCountOfSelectedAccidents is cancelled 2 ----------")
                    return
                }
                let countOfAllAccidents = try asyncContext.count(for: countAllAccidentsRequest)

                if Task.isCancelled {
                    print("------Task fetchCountOfSelectedAccidents is cancelled 3 ----------")
                    return
                }
                DispatchQueue.main.async {
                    print("------------ IN MAIN QUEUE OF fetchCountOfSelectedAccidents --------------")
                    if Task.isCancelled {
                        print("------Task fetchCountOfSelectedAccidents is cancelled 4 ----------")
                        return
                    }
                    self.countOfSelectedAccidents = countOfAllAccidents
                }
            }
            catch {
                fatalError()
            }
        }
    }
    
    
    /// Loads accidents for the region from the database.
    func fetchAccidents(region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.66, longitude: 9.11), latitudinalMeters: 1000, longitudinalMeters: 1000)) {
        
        DispatchQueue.main.async {
            self.isFetchingAccidents = true
        }
        
        if Task.isCancelled {
            print("------Task is cancelled in fetchAccidents 0 ----------")
            return
        }
        
        asyncContext.performAndWait { [unowned self] in
            do {

                let request = Accident.fetchRequest()
                print("AccidentDataFilters.predicates: \(accidentDataFilters.predicates)")
                
                if region.areaInSquareKilometers >= 15000 {
                    
                    let countPredicate = self.countPredicate(region: region, countOfSelectedAccidents: countOfSelectedAccidents)
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [countPredicate] + [region.predicate] + accidentDataFilters.predicates)
                } else if region.areaInSquareKilometers < 15000 {
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + accidentDataFilters.predicates)
                }
                                
                if Task.isCancelled {
                    print("------Task is in fetchAccidents 1 ----------")
                    return
                }

                // Fetch count of accidents in region -> consumes too much time, thus only used for debugging
//                let countOfAccidentsInRegion = try self.asyncContext.count(for: request)
//                DispatchQueue.main.async {
//                    self.countOfAccidentsInRegion = countOfAccidentsInRegion
//                }

                if Task.isCancelled {
                    print("------Task is cancelled in fetchAccidents 2 ----------")
                    return
                }

                // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
//                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]

                request.fetchLimit = fetchLimit
                let accidents =  try self.asyncContext.fetch(request)

                if Task.isCancelled {
                    print("------Task is cancelled in fetchAccidents 3 ----------")
                    return
                }
                DispatchQueue.main.async {
                    self.accidents = accidents
                    self.isFetchingAccidents = false
                }
            }
            catch {
                fatalError()
            }
        }
        
        if Task.isCancelled {
            print("------Task is cancelled in fetchAccidents 3 ----------")
            return
        }
    }
    
    /// Special predicate that reduces the overall number of accidents with respect to the region and the overall amount of selected accidents, such that always enough accidents are in the region, but not much mor.
    func countPredicate(region: MKCoordinateRegion, countOfSelectedAccidents: Int, allAccidentsCount: Int = ViewModel.countOfAllAccidents) -> NSPredicate {
        
        let areaGermany = 357_588.0
        let neededAccidentsForArea = 20_000.0
        
        var neededDensityForArea = neededAccidentsForArea / region.areaInSquareKilometers
        if countOfSelectedAccidents != 0 {
            neededDensityForArea = neededDensityForArea * Double(allAccidentsCount) / Double(countOfSelectedAccidents)
        }
        var neededCountForGermany = min( Int(ceil(areaGermany * neededDensityForArea)), allAccidentsCount)
        neededCountForGermany = max(neededCountForGermany, 200_000)
        let setOfCounts = Array(stride(from: 0, through: 1_500_000, by: 100_000))
        let lastIndex = setOfCounts.lastIndex(where: {$0 <= neededCountForGermany})!

        let setOfCountsForFetch = Array(setOfCounts[0...lastIndex])

//        print("Area: \(region.areaInSquareKilometers), needed density for area: \(neededDensityForArea), needed count for Germany: \(neededCountForGermany)")
//        print("Set of Counts: \(setOfCounts)")
//        print("Last index: \(lastIndex)")
//        print("Resulting set: \(setOfCountsForFetch)")
                                                    
        let countPredicate = NSPredicate(format: "countOfAccidentsBy100000 IN %@", setOfCountsForFetch)
        
        print("Predicate for counts: \(countPredicate.description)")
        
        return countPredicate
    }

}
