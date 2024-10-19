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

@MainActor
final class ViewModel: ObservableObject {
    
    // static let countOfAllAccidents = 1_554_834 // with 2022 date. Value to be filled in by hand, whenever new data files for new years are added.
    // count of all accidents in the database when all the years are imported into the database
    static let countOfAllAccidents = 1_823_882 // With 2023 data. Value to filled in by hand, whenever new data files for new years are added.
    // count of all accidents in the database if no filter/seletion is applied, otherwhise the count of the accidents in the database after filtering/selection
    @Published var countOfSelectedAccidents: Int = 0
    // count of the subset of the accidents in the database that lies in the respective region (geographic rectangular), filter/selection applied.
    // Number is limited by fetchlimit, thus it can be a number from 0 up to fetchLimit.
    @Published var countOfAccidentsInRegion: Int = 0
    // Accidents to be displayed, i.e. the accidents in the respective region (0 up to fetchLimit accidents)
//    @Published var accidents: [Accident] = []
    @Published var accidentStructs: [AccidentStruct] = []
    
    @Published var isFetchingAccidents = false
    @Published var accidentDataFilters = AccidentDataFilter()
    private var fetchOperation3: FetchOperation? = nil
    private var taskForFetchingSelectedAccidents: Task<Void, Error>? = nil

//    private let asyncContext = PersistenceController.shared.container.newBackgroundContext()
    private(set) var fetchLimit = 400 //300 // Maximum number of accidents to fetched -> fetchLimit for fetch request.
//    private var taskForCountingSelectedAccidents: Task<Void, Never>? = nil
    private var taskForFetchingAccidents: Task<Void, Never>? = nil
    
//    private var asyncFetchResult: NSAsynchronousFetchResult<any NSFetchRequestResult>?
//    private let newAsyncContext = PersistenceController.shared.container.newBackgroundContext()

    @Published var isFetchingCountOfSelectedAccidents = false
//    private var fetchOperation: FetchOperationForCountFetchRequest? = nil
    private var fetchOperation2: FetchOperation? = nil
    private var taskForCountingSelectedAccidents: Task<Void, Error>? = nil
    
    init(initFromFile: Bool = false) {
//        asyncContext.automaticallyMergesChangesFromParent = true
        
        let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
        NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)), name: didSaveNotification, object: nil)
#if DEBUG
        print("Running in debug mode.")
#else
        print("Running in release mode.")
#endif
    }
    
    /// Called when context was saved. Updates the count of selected accidents in the respective view.
    /// - Parameter notification: This parameter is not used
    @objc func didSave(_ notification: Notification) {
        getCountOfSelectedAccidents()
    }
  
    
    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
    func fetchAccidents(region: MKCoordinateRegion)  {
        
        // Detached task does NOT run on the main thread and needs to be called with await.
        taskForFetchingAccidents?.cancel()
        taskForFetchingAccidents = Task.detached(priority: .high) {
            
            await MainActor.run { self.isFetchingAccidents = true }
            
            // Fetchrequest
            let request = Accident.fetchRequest()
            request.fetchLimit = await self.fetchLimit
            request.fetchBatchSize = 50
            
            //Predicates
            let predicates = await self.accidentDataFilters.predicates
            if region.areaInSquareKilometers >= 15000 && predicates.isEmpty {
                let newCountPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [UnfallJahr.jahr2022.predicate!] + [UnfallJahr.jahr2021.predicate!])
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newCountPredicate] + [region.predicate])
            } else {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + predicates)
            }
            
            // Sortdescriptors
            // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
            //                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]
            
            if Task.isCancelled {
                print("------Task is cancelled in new fetchAccidents 0 ----------")
                return
            }
            
            // Background context and execution of fetch request
            let newContext = PersistenceController.shared.container.newBackgroundContext()
            var accidents: [Accident] = []
            var accidentStructs: [AccidentStruct] = []
            try? newContext.performAndWait {
                print("Im Context")
                accidents =  try newContext.fetch(request)
                
                for accident in accidents {
                    accidentStructs.append(
                        AccidentStruct(
                            accidentObjectID: accident.accidentObjectID,
                            istFahrrad: accident.istFahrrad,
                            istFussgaenger: accident.istFussgaenger,
                            istGueterKfz: accident.istGueterKfz,
                            istKrad: accident.istKrad,
                            istPkw: accident.istPkw,
                            istSonstige: accident.istPkw,
                            jahr: accident.jahr,
                            land: accident.land,
                            lattitude: accident.lattitude,
                            lichtVerhaeltnisse: accident.lichtVerhaeltnisse,
                            longitude: accident.longitude,
                            monat: accident.monat,
                            strassenZustand: accident.strassenZustand,
                            stunde: accident.stunde,
                            unfallArt: accident.unfallArt,
                            unfallKategorie: accident.unfallKategorie,
                            unfallTyp1: accident.unfallTyp1,
                            wochentag: accident.wochentag
                        )
                    )
                }

            }
            
            if Task.isCancelled {
                print("------Task is cancelled in new fetchAccidents 1 ----------")
                return
            }
            
            
            Task { @MainActor [unowned self, accidents ] in
//                self.accidents = accidents // App crashes here, when enabling '-com.apple.CoreData.ConcurrencyDebug 1'. Probably because NSManagedObject is not sendable.
                self.accidentStructs = accidentStructs
                print("Count of accidents is: \(accidentStructs.count)")

                self.isFetchingAccidents = false
            }
            
            await print("AccidentDataFilters.predicates: \(self.accidentDataFilters.predicates)")
        }
    }
    
//    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
//    func fetchAccidents(region: MKCoordinateRegion)  {
//        
//        // Detached task does NOT run on the main thread and needs to be called with await.
//        taskForFetchingAccidents?.cancel()
//        taskForFetchingAccidents = Task.detached(priority: .high) {
//            
//            await MainActor.run { self.isFetchingAccidents = true }
//            
//            // Fetchrequest
//            let request = Accident.fetchRequest()
//            request.fetchLimit = await self.fetchLimit
//            request.fetchBatchSize = 50
//            
//            //Predicates
//            let predicates = await self.accidentDataFilters.predicates
//            if region.areaInSquareKilometers >= 15000 && predicates.isEmpty {
//                let newCountPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [UnfallJahr.jahr2022.predicate!] + [UnfallJahr.jahr2021.predicate!])
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newCountPredicate] + [region.predicate])
//            } else {
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + predicates)
//            }
//            
//            // Sortdescriptors
//            // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
//            //                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
//            request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]
//            
//            if Task.isCancelled {
//                print("------Task is cancelled in new fetchAccidents 0 ----------")
//                return
//            }
//            
//            // Background context and execution of fetch request
//            let newContext = PersistenceController.shared.container.newBackgroundContext()
//            var accidents: [Accident] = []
//            try? newContext.performAndWait {
//                print("Im Context")
//                accidents =  try newContext.fetch(request)
//            }
//            
//            if Task.isCancelled {
//                print("------Task is cancelled in new fetchAccidents 1 ----------")
//                return
//            }
//            
//            // Warning in Swift 5, but error in Swift 6 (allthough it works nicely)
//            // Task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
//            Task { @MainActor [unowned self, accidents ] in
//                self.accidents = accidents
//                self.isFetchingAccidents = false
//            }
//            
//            await print("AccidentDataFilters.predicates: \(self.accidentDataFilters.predicates)")
//        }
//    }

    
//    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
//    func fetchAccidentsAsync(region: MKCoordinateRegion) async {
//        if Task.isCancelled {
//            print("------Task is cancelled 0 ----------")
//            return
//        }
//        
//        /// THIS CODE RUNS ON SWIFT 5, BUT ON THE MAIN ACTOR. Calling fetchAccidents from here results in an unresponsive UI (filter on "tocken" and "tageslicht")
//        //        self.fetchAccidents(region: region)
//        //        return;
//        
//        
//        // Detached task does NOT run on the main thread and needs to be called with await.
//        detachedTask?.cancel()
//        detachedTask = Task.detached(priority: .high) {
//            
//            //        Task() { // Using just Task() runs on the main thread and does not need await
//            /// THIS CODE RUNS ON SWIFT 5, BUT ON THE MAIN ACTOR. Calling from here also results in a rather unresponsive UI (filter on "tocken" and "tageslicht")
//            //            await self.fetchAccidents(region: region)
//            //            return;
//            
//            /// THE CODE BELOW RUNS (VERY WELL) ON SWIFT 5 (NOT ON THE MAIN ACTOR/THREAD BUT ON A SEPARATE THREAD). IT DOES NOT RUN ON SWIFT 6
//            /// This results in the most responsive UI. Follow this path!!! (filter on "tocken" and "tageslicht"))
//            // New code trial with detached task.
//            await MainActor.run { self.isFetchingAccidents = true }
//            
//            // Fetchrequest
//            let request = Accident.fetchRequest()
//            request.fetchLimit = await self.fetchLimit
//            request.fetchBatchSize = 50
//            
//            //Predicates
//            let predicates = await self.accidentDataFilters.predicates
//            if region.areaInSquareKilometers >= 15000 && predicates.isEmpty {
//                let newCountPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [UnfallJahr.jahr2022.predicate!] + [UnfallJahr.jahr2021.predicate!])
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newCountPredicate] + [region.predicate])
//            } else {
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + predicates)
//            }
//            
//            // Sortdescriptors
//            // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
//            //                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
//            request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]
//            
//            if Task.isCancelled {
//                print("------Task is cancelled in new fetchAccidents 0 ----------")
//                return
//            }
//            
//            // Background context and execution of fetch request
//            let newContext = PersistenceController.shared.container.newBackgroundContext()
//            var accidents: [Accident] = []
//            try? newContext.performAndWait {
//                print("Im Context")
//                accidents =  try newContext.fetch(request)
//            }
//            
//            if Task.isCancelled {
//                print("------Task is cancelled in new fetchAccidents 1 ----------")
//                return
//            }
//            
//            // Warning in Swift 5, but error in Swift 6 (allthough it works nicely)
//            // Task or actor isolated value cannot be sent; this is an error in the Swift 6 language mode
//            Task { @MainActor [unowned self, accidents ] in
//                self.accidents = accidents
//                self.isFetchingAccidents = false
//            }
//            
//            await print("AccidentDataFilters.predicates: \(self.accidentDataFilters.predicates)")
//        }
//    }
//    
    
//    func fetchAccidents(region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.66, longitude: 9.11), latitudinalMeters: 1000, longitudinalMeters: 1000)) {
//        
//        DispatchQueue.main.async {
//            self.isFetchingAccidents = true
//        }
//        
//        if Task.isCancelled {
//            print("------Task is cancelled in fetchAccidents 0 ----------")
//            return
//        }
//        
//        let newContext = PersistenceController.shared.container.newBackgroundContext()
//        
//        newContext.performAndWait { [unowned self] in
//            do {
//                let request = Accident.fetchRequest()
//                //                Task {@MainActor in
//                //                    print("AccidentDataFilters.predicates: \(accidentDataFilters.predicates)")
//                //                    }
//                print("Accident DataFilters.predicates: \(self.accidentDataFilters.predicates)")
//                
//                // If area is large, reduce the amount of data selected using the so called countPrdicate.
//                // This may not be used (and is not necessary) if a certain year is selected, sincethe count predicate omits some years and results could be wrong.
//                //                if region.areaInSquareKilometers >= 15000 && accidentDataFilters.jahr.predicate == nil {
//                if region.areaInSquareKilometers >= 15000 && accidentDataFilters.predicates.isEmpty {
//                    let countPredicate = self.countPredicate(region: region, countOfSelectedAccidents: countOfSelectedAccidents)
//                    //                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [countPredicate] + [region.predicate] + accidentDataFilters.predicates)
//                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [countPredicate] + [region.predicate])
//                } else {
//                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + accidentDataFilters.predicates)
//                }
//                
//                if Task.isCancelled {
//                    print("------Task is in fetchAccidents 1 ----------")
//                    return
//                }
//                
//                // Fetch count of accidents in region -> consumes too much time, thus only used for debugging
//                //                let countOfAccidentsInRegion = try self.asyncContext.count(for: request)
//                //                DispatchQueue.main.async {
//                //                    self.countOfAccidentsInRegion = countOfAccidentsInRegion
//                //                }
//                
//                if Task.isCancelled {
//                    print("------Task is cancelled in fetchAccidents 2 ----------")
//                    return
//                }
//                
//                // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
//                //                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
//                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]
//                
//                request.fetchLimit = fetchLimit
//                request.fetchBatchSize = 50
//                let accidents =  try self.asyncContext.fetch(request)
//                
//                if Task.isCancelled {
//                    print("------Task is cancelled in fetchAccidents 3 ----------")
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    self.accidents = accidents
//                    self.isFetchingAccidents = false
//                }
//            }
//            catch {
//                fatalError()
//            }
//        }
//        
//        if Task.isCancelled {
//            print("------Task is cancelled in fetchAccidents 3 ----------")
//            return
//        }
//    }
    
//    /// Special predicate that reduces the overall number of accidents with respect to the region and the overall amount of selected accidents, such that always enough accidents are in the region, but not much more.
//    func countPredicate(region: MKCoordinateRegion, countOfSelectedAccidents: Int, allAccidentsCount: Int = ViewModel.countOfAllAccidents) -> NSPredicate {
//        
//        let areaGermany = 357_588.0 // Area of Germany in square kilometers
//        let neededAccidentsForArea = 20_000.0 // We want at least 20_000 accidents as a basis in the respective area
//        
//        var neededDensityForArea = neededAccidentsForArea / region.areaInSquareKilometers
//        if countOfSelectedAccidents != 0 {
//            neededDensityForArea = neededDensityForArea * Double(allAccidentsCount) / Double(countOfSelectedAccidents)
//        }
//        var neededCountForGermany = min( Int(ceil(areaGermany * neededDensityForArea)), allAccidentsCount)
//        neededCountForGermany = max(neededCountForGermany, 200_000)
//        //        let setOfCounts = Array(stride(from: 0, through: 1_500_000, by: 100_000))
//        let setOfCounts = Array(stride(from: 0, through: 1_800_000, by: 100_000))
//        let lastIndex = setOfCounts.lastIndex(where: {$0 <= neededCountForGermany})!
//        
//        let setOfCountsForFetch = Array(setOfCounts[0...lastIndex])
//        
//        print("Area: \(region.areaInSquareKilometers), needed density for area: \(neededDensityForArea), needed count for Germany: \(neededCountForGermany)")
//        print("Set of Counts: \(setOfCounts)")
//        print("Last index: \(lastIndex)")
//        print("Resulting set: \(setOfCountsForFetch)")
//        
//        //        let countPredicate = NSPredicate(format: "countOfAccidentsBy100000 IN %@", setOfCountsForFetch)
//        //        print("Predicate for counts: \(countPredicate.description)")
//        //        return countPredicate
//        
//        // Test with new approach just selection 2022 if no year is selected and density is correct.
//        //        let newCountPredicate = UnfallJahr.jahr2022.predicate!
//        let newCountPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [UnfallJahr.jahr2022.predicate!] + [UnfallJahr.jahr2021.predicate!])
//        print("Predicate for counts: \(newCountPredicate.description)")
//        return newCountPredicate
//    }
    
    
//    /// Loads the count of selected accidents from the database.
//    ///
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region.
//    nonisolated func fetchCountOfSelectedAccidents2() async {
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 0 ----------")
//            return
//        }
//        
//        let countAllAccidentsRequest = Accident.fetchRequest()
//        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: await accidentDataFilters.predicates)
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 2 ----------")
//            return
//        }
//        
//        let newContext = PersistenceController.shared.container.newBackgroundContext()
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 2b ----------")
//            
//            newContext.reset()
//            return
//        }
//        newContext.performAndWait { [unowned self] in
//            if Task.isCancelled {
//                print("------Task fetchCountOfSelectedAccidents2 is cancelled 3 ----------")
//                return
//            }
//            let countOfAllAccidents = try? newContext.count(for: countAllAccidentsRequest)
//            if Task.isCancelled {
//                print("------Task fetchCountOfSelectedAccidents2 is cancelled 4 ----------")
//                return
//            }
//            Task {@MainActor in
//                print("------------ IN MAIN QUEUE OF fetchCountOfSelectedAccidents2 --------------")
//                self.countOfSelectedAccidents = countOfAllAccidents ?? -1
//            }
//        }
//    }
//    
//
    
//    /// Loads the count of selected accidents from the database.
//    ///
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region.
//    func fetchCountOfSelectedAccidents() async {
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents is cancelled 0 ----------")
//            return
//        }
//        
//        asyncContext.performAndWait { [unowned self] in
//            do {
//                if Task.isCancelled {
//                    print("------Task fetchCountOfSelectedAccidents is cancelled 1 ----------")
//                    return
//                }
//                let countAllAccidentsRequest = Accident.fetchRequest()
//                countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)
//                
//                if Task.isCancelled {
//                    print("------Task fetchCountOfSelectedAccidents is cancelled 2 ----------")
//                    return
//                }
//                let countOfAllAccidents = try asyncContext.count(for: countAllAccidentsRequest)
//                
//                if Task.isCancelled {
//                    print("------Task fetchCountOfSelectedAccidents is cancelled 3 ----------")
//                    return
//                }
//                DispatchQueue.main.async {
//                    print("------------ IN MAIN QUEUE OF fetchCountOfSelectedAccidents --------------")
//                    if Task.isCancelled {
//                        print("------Task fetchCountOfSelectedAccidents is cancelled 4 ----------")
//                        return
//                    }
//                    self.countOfSelectedAccidents = countOfAllAccidents
//                }
//            }
//            catch {
//                fatalError()
//            }
//        }
//    }
//    
//    /// Loads the count of selected accidents from the database.
//    ///
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region.
//    nonisolated func fetchCountOfSelectedAccidents3() async {
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 0 ----------")
//            return
//        }
//        
//        let countAllAccidentsRequest = Accident.fetchRequest()
//        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: await accidentDataFilters.predicates)
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 2 ----------")
//            return
//        }
//        
//        let newContext = PersistenceController.shared.container.newBackgroundContext()
//        newContext.performAndWait { [unowned self] in
//
//            if Task.isCancelled {
//                print("------Task fetchCountOfSelectedAccidents2 is cancelled 3 ----------")
//                return
//            }
//            let countOfAllAccidents = try? newContext.count(for: countAllAccidentsRequest)
//            if Task.isCancelled {
//                print("------Task fetchCountOfSelectedAccidents2 is cancelled 4 ----------")
//                return
//            }
//            Task {@MainActor in
//                print("------------ IN MAIN QUEUE OF fetchCountOfSelectedAccidents2 --------------")
//                self.countOfSelectedAccidents = countOfAllAccidents ?? -1
//            }
//        }
//    }
//        
//    /// Loads the count of selected accidents from the database.
//    ///
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region.
//    @MainActor func fetchCountOfSelectedAccidents4()  {
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 0 ----------")
//            return
//        }
//        
//        let countAllAccidentsRequest = Accident.fetchRequest()
//        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:  accidentDataFilters.predicates)
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 2 ----------")
//            return
//        }
//        
//        //        performFetchRequest(predicate: countAllAccidentsRequest.predicate!)
//        let asyncRequest = Accident.fetchRequest()
//        asyncRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:  accidentDataFilters.predicates)
////        asyncRequest.fetchLimit = 20000
////        asyncRequest.resultType = .countResultType // Does not work with .countResultType. Maybe this is a bug.
//        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: asyncRequest) { [weak self] (result: NSAsynchronousFetchResult) in
//            // Handle the result
//            print("In final results of fetchrequest: \(result.description)")
//            if let finalResult = result.finalResult {
//                // Process the fetched objects
//                //                print("In final results of fetchrequest: \(finalResult.description)")
//                print("Zahl der Unfälle 4: \(finalResult.count)")
//                self?.countOfSelectedAccidents = finalResult.count
//            }
//        }
//        
//        asyncFetchResult?.cancel()
////        var asyncFetchResult: NSAsynchronousFetchResult<any NSFetchRequestResult>?
////        asyncFetchResult = try? PersistenceController.shared.container.viewContext.execute(asyncFetchRequest) as?  NSAsynchronousFetchResult
//        
//        PersistenceController.shared.container.viewContext.perform { [weak self] in
//            do {
//                self?.asyncFetchResult = try PersistenceController.shared.container.viewContext.execute(asyncFetchRequest) as? NSAsynchronousFetchResult
//            } catch let error {
//                print("There was an error: \(error). Arrgh.")
//            }
//        }
//            
//    }
//
//    /// Loads the count of selected accidents from the database.
//    ///
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region.
//    func fetchCountOfSelectedAccidents5() async {
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 0 ----------")
//            return
//        }
//        
//        let countAllAccidentsRequest = Accident.fetchRequest()
//        countAllAccidentsRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)
//        
//        if Task.isCancelled {
//            print("------Task fetchCountOfSelectedAccidents2 is cancelled 2 ----------")
//            return
//        }
//        
////        let newContext = PersistenceController.shared.container.newBackgroundContext()
////        newContext.perform { [unowned self] in
//
//        newAsyncContext.performAndWait { [weak self] in
//            print("perform 5 gestartet")
//            if Task.isCancelled {
//                print("------Task fetchCountOfSelectedAccidents2 is cancelled 3 ----------")
//                return
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                // Put your code which should be executed with a delay here
//                print("Context resettet gleich")
//                self?.newAsyncContext.reset()
//                print("Context hat resettet")
//            }
//            
//            let countOfAllAccidents = try? self?.newAsyncContext.count(for: countAllAccidentsRequest)
//            print("perform 5 hinter Datenbankabfrage")
//            if Task.isCancelled {
//                print("------Task fetchCountOfSelectedAccidents2 is cancelled 4 ----------")
//                return
//            }
//            Task {@MainActor in
//                print("------------ IN MAIN QUEUE OF fetchCountOfSelectedAccidents2 --------------")
//                self?.countOfSelectedAccidents = countOfAllAccidents ?? -1
//            }
//        }
//
//    }
//        
// 
//    
//    
//    /// Loads the count of selected accidents for the current selection (i.e. filters set)from the database.
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region, but always for whole Germany.
//    /// Uses Operation. Operations can be cancelled and thus a running fetch request on that operation will be cancelled together with this operation.
//    /// Changed to this version due to Swift 6.
//    func performFetchRequest(predicate: NSPredicate) -> FetchOperationForCountFetchRequest {
//
//        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Accident")
//        fetchRequest.predicate = predicate
//
//        let context = PersistenceController.shared.container.newBackgroundContext()
//        let fetchOperation = FetchOperationForCountFetchRequest(context: context, fetchRequest: fetchRequest)
//
//        let operationQueue = OperationQueue()
//        operationQueue.addOperation(fetchOperation)
//
//        return fetchOperation
//    }
   
    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
    func fetchAccidents2(region: MKCoordinateRegion)  {
        
        isFetchingAccidents = true
        
        // Fetchrequest
//        let request = Accident.fetchRequest()
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Accident")
        request.fetchLimit = fetchLimit
        request.fetchBatchSize = 50
        request.resultType = .managedObjectResultType
        
        //Predicates
        let predicates = accidentDataFilters.predicates
        if region.areaInSquareKilometers >= 15000 && predicates.isEmpty {
            let newCountPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [UnfallJahr.jahr2022.predicate!] + [UnfallJahr.jahr2021.predicate!])
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newCountPredicate] + [region.predicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + predicates)
        }
        
        // Sortdescriptors
        // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
        //                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]
        
        fetchOperation3?.cancel()
        fetchOperation3 = performFetchRequest(fetchRequest: request)

        // Task needed for polling the results from the fetch operation
        taskForFetchingSelectedAccidents?.cancel()
        taskForFetchingSelectedAccidents = Task {
            // Do something

            while true {
                guard !Task.isCancelled else {
                    print("I task was cancelled")
                    break
                }
                if let fetchOperation3, fetchOperation3.isCancelled {
                    print("fetchOperation cancelled")
                    break
                }
                if let fetchOperation3, fetchOperation3.isFinished {
                    print("fetchOperation3 finished")
                    isFetchingAccidents = false
                    accidentStructs = fetchOperation3.accidentStructs
                    print("Erster: \(accidentStructs.first?.accidentObjectID)")
                    break
                }
                print("I will wail a little bit...")

                try await Task.sleep(nanoseconds: 100_000_000) // Polling every 100 ms
            }
            print("I will return...")
            return
        }

            
    }

    
    
    func getCountOfSelectedAccidents() {
        
        isFetchingCountOfSelectedAccidents = true

        taskForCountingSelectedAccidents?.cancel()
//        fetchOperation?.cancel()
//        fetchOperation = performCountFetchRequest(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates))
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Accident")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)
        fetchRequest.resultType = .countResultType

        fetchOperation2?.cancel()
//        fetchOperation2 = performCountFetchRequest2(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates))
        fetchOperation2 = performFetchRequest(fetchRequest: fetchRequest)

        // Task needed for polling the results from the fetch operation
        taskForCountingSelectedAccidents = Task {
            // Do something

            while true {
                guard !Task.isCancelled else {
                    print("I task was cancelled")
                    break
                }
                if let fetchOperation2, fetchOperation2.isCancelled {
                    print("fetchOperation cancelled")
                    break
                }
                if let fetchOperation2, fetchOperation2.isFinished {
                    print("fetchOperation finished")
                    isFetchingCountOfSelectedAccidents = false
                    countOfSelectedAccidents = fetchOperation2.count ?? 0
                    print("# of accidents: \(countOfSelectedAccidents)")
                    break
                }
                print("I will wail a little bit...")

                try await Task.sleep(nanoseconds: 100_000_000) // Polling every 100 ms
            }
            print("I will return...")
            return
        }
    }
    
    
//    /// Loads the count of selected accidents for the current selection (i.e. filters set)from the database.
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region, but always for whole Germany.
//    /// Uses Operation. Operations can be cancelled and thus a running fetch request on that operation will be cancelled together with this operation.
//    /// Changed to this version due to Swift 6.
//    func performCountFetchRequest(predicate: NSPredicate) -> FetchOperationForCountFetchRequest {
//
//        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Accident")
//        fetchRequest.predicate = predicate
//
//        let context = PersistenceController.shared.container.newBackgroundContext()
//        let fetchOperation = FetchOperationForCountFetchRequest(context: context, fetchRequest: fetchRequest)
//
//        let operationQueue = OperationQueue()
//        operationQueue.addOperation(fetchOperation)
//
//        return fetchOperation
//    }
    
    /// Loads the count of selected accidents for the current selection (i.e. filters set)from the database.
    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region, but always for whole Germany.
    /// Uses Operation. Operations can be cancelled and thus a running fetch request on that operation will be cancelled together with this operation.
    /// Changed to this version due to Swift 6.
    func performFetchRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> FetchOperation {

        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchOperation = FetchOperation(context: context, fetchRequest: fetchRequest)

        let operationQueue = OperationQueue()
        operationQueue.addOperation(fetchOperation)

        return fetchOperation
    }
    
    
    /// Loads the count of selected accidents for the current selection (i.e. filters set)from the database.
    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region, but always for whole Germany.
    /// Uses Operation. Operations can be cancelled and thus a running fetch request on that operation will be cancelled together with this operation.
    /// Changed to this version due to Swift 6.
    func performCountFetchRequest2(predicate: NSPredicate) -> FetchOperation {

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Accident")
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .countResultType

        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchOperation = FetchOperation(context: context, fetchRequest: fetchRequest)

        let operationQueue = OperationQueue()
        operationQueue.addOperation(fetchOperation)

        return fetchOperation
    }
}


/// Creates an Operation and runs a fetch request on it that returns the count of objects in the database for the request.
///
/// Advantage is that the operation can be cancelled and with the cancellation the (possibly long running) fetch request will be cancelled, too. Furthermore, this runs on a background thread and the UI remains responsive.
///
/// Disadvantage is that the results "appear" after some time (during that the operation can be cancelled). Thus, polling has to be implemented until the results are available (operation finshed) or the operation is cancelled.
//class FetchOperationForCountFetchRequest: Operation, @unchecked Sendable {
//
//    /// The managed object context for the fetch request
//    private let context: NSManagedObjectContext
//    /// The fetch request
//    private let fetchRequest: NSFetchRequest<NSManagedObject>
//    /// The count of the objects in the data base, if the fetch request was successfull, otherwhise nil.
//    var count: Int? = nil
//
//    init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<NSManagedObject>) {
//        self.context = context
//        self.fetchRequest = fetchRequest
//    }
//
//    override func main() {
//        if isCancelled {
//            return
//        }
//
//        context.performAndWait {
//            do {
////                let hugo = try context.fetch(fetchRequest)
//                let result = try context.count(for: fetchRequest)
//                if !self.isCancelled {
//                    // Make use of the results
//                    self.count = result
////                    print("Fetched \(result) objects")
//
//                } else {
//                    self.count = nil
//                }
//            } catch {
//                if !self.isCancelled {
//                    print("Fetch request failed: \(error)")
//                }
//                self.count = nil
//            }
//        }
//    }
//}

/// Creates an Operation and runs a fetch request on it.
/// If the result type is .countType, then the count property will be filled with the count of respective objects in the database.
///
/// Advantage is that the operation can be cancelled and with the cancellation the (possibly long running) fetch request will be cancelled, too. Furthermore, this runs on a background thread and the UI remains responsive.
///
/// Disadvantage is that the results "appear" after some time (during that the operation can be cancelled). Thus, polling has to be implemented until the results are available (operation finshed) or the operation is cancelled.
class FetchOperation: Operation, @unchecked Sendable {
//    class FetchOperation: Operation, @unchecked Sendable {

    /// The managed object context for the fetch request
    private let context: NSManagedObjectContext
    /// The fetch request
    private let fetchRequest: NSFetchRequest<NSFetchRequestResult>
    /// The count of the objects in the data base, if the fetch request was successfull, otherwhise nil.
    var count: Int? = nil
    var accidents: [Accident] = []
    var accidentStructs: [AccidentStruct] = []

    init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.context = context
        self.fetchRequest = fetchRequest
    }

    override func main() {
        if isCancelled {
            return
        }

        context.performAndWait {
            do {
                let result = try context.fetch(fetchRequest)
//                let result = try context.count(for: fetchRequest)
                if !self.isCancelled {
                    // Make use of the results
//                    print("Type of the result: \(result.description)")
                    if let result = result as? [NSNumber] {
//                        print("Type of the result: \(result.description)")
                        self.count = result.first?.intValue
                    } else if let result = result as? [Accident] {
//                        print("Type of the result: \(result.description)")
                        self.accidents = result
                        for accident in self.accidents {
                            self.accidentStructs.append(
                                AccidentStruct(
                                    accidentObjectID: accident.accidentObjectID,
                                    istFahrrad: accident.istFahrrad,
                                    istFussgaenger: accident.istFussgaenger,
                                    istGueterKfz: accident.istGueterKfz,
                                    istKrad: accident.istKrad,
                                    istPkw: accident.istPkw,
                                    istSonstige: accident.istPkw,
                                    jahr: accident.jahr,
                                    land: accident.land,
                                    lattitude: accident.lattitude,
                                    lichtVerhaeltnisse: accident.lichtVerhaeltnisse,
                                    longitude: accident.longitude,
                                    monat: accident.monat,
                                    strassenZustand: accident.strassenZustand,
                                    stunde: accident.stunde,
                                    unfallArt: accident.unfallArt,
                                    unfallKategorie: accident.unfallKategorie,
                                    unfallTyp1: accident.unfallTyp1,
                                    wochentag: accident.wochentag
                                )
                            )
                        }
                        
                        self.count = result.count
                    }
//                    print("Fetched \(result) objects")

                } else {
                    self.count = nil
                }
            } catch {
                if !self.isCancelled {
                    print("Fetch request failed: \(error)")
                }
                self.count = nil
            }
        }
    }
}


