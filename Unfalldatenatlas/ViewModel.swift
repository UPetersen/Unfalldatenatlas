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
    @Published var accidentStructs: [AccidentStruct] = []
    
    @Published var isFetchingAccidents = false
    @Published var accidentDataFilters = AccidentDataFilter()
    private var fetchOperation3: FetchOperation? = nil
    private var taskForFetchingSelectedAccidents: Task<Void, Error>? = nil

    private(set) var fetchLimit = 400 //300 // Maximum number of accidents to fetched -> fetchLimit for fetch request.
    private var taskForFetchingAccidents: Task<Void, Never>? = nil
    
    @Published var isFetchingCountOfSelectedAccidents = false
    private var fetchOperation: FetchOperation? = nil
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
                            wochentag: accident.wochentag,
                            coordinate: accident.coordinate,
                            color: accident.color
                        )
                    )
                }
            }
            
            if Task.isCancelled {
                print("------Task is cancelled in new fetchAccidents 1 ----------")
                return
            }
            
            
            Task { @MainActor [unowned self, accidentStructs ] in
                self.accidentStructs = accidentStructs
                print("Count of accidents is: \(accidentStructs.count)")

                self.isFetchingAccidents = false
            }
            
            await print("AccidentDataFilters.predicates: \(self.accidentDataFilters.predicates)")
        }
    }

   
    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
    func fetchAccidents2(region: MKCoordinateRegion)  {
        
        isFetchingAccidents = true
        
        // Fetchrequest. Must use NSFetchedRequestResult as type, this enables general handling in class FetchOperation. (Then works with fetching managed objects as well as just the count.)
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
//                    print("Erster: \(accidentStructs.first?.accidentObjectID ?? -99)")
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Accident")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)
        fetchRequest.resultType = .countResultType

        fetchOperation?.cancel()
        fetchOperation = performFetchRequest(fetchRequest: fetchRequest)

        // Task needed for polling the results from the fetch operation
        taskForCountingSelectedAccidents = Task {
            // Do something

            while true {
                guard !Task.isCancelled else {
                    print("I task was cancelled")
                    break
                }
                if let fetchOperation, fetchOperation.isCancelled {
                    print("fetchOperation cancelled")
                    break
                }
                if let fetchOperation, fetchOperation.isFinished {
                    print("fetchOperation finished")
                    isFetchingCountOfSelectedAccidents = false
                    countOfSelectedAccidents = fetchOperation.count ?? 0
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


/// Creates an Operation and runs a fetch request on it.
/// If the result type is .countType, then the count property will be filled with the count of respective objects in the database.
///
/// Advantage is that the operation can be cancelled and with the cancellation the (possibly long running) fetch request will be cancelled, too. Furthermore, this runs on a background thread and the UI remains responsive.
///
/// Disadvantage is that the results "appear" after some time (during that the operation can be cancelled). Thus, polling has to be implemented until the results are available (operation finshed) or the operation is cancelled.
class FetchOperation: Operation, @unchecked Sendable {

    /// The managed object context for the fetch request
    private let context: NSManagedObjectContext
    /// The fetch request
    private let fetchRequest: NSFetchRequest<NSFetchRequestResult>
    /// The count of the objects in the data base, if the fetch request was successfull, otherwhise nil.
    var count: Int? = nil
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
                if !self.isCancelled {
                    // Make use of the results
                    if let result = result as? [NSNumber] {
                        self.count = result.first?.intValue
                    } else if let accidents = result as? [Accident] {
                        for accident in accidents {
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
                                    wochentag: accident.wochentag,
                                    coordinate: accident.coordinate,
                                    color: accident.color
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


