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
import GRDB


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
//    var land = Land.keineAuswahl
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
        return [
            istFahrrad.predicateNeu,
            istFussgaenger.predicateNeu,
            istGueterKfz.predicateNeu,
            istKrad.predicateNeu,
            istPkw.predicateNeu,
            istSonstige.predicateNeu,
            
            unfallArt.predicate,
            unfallKategorie.predicate,
            unfallTyp1.predicate,
            lichtVerhaeltnisse.predicate,
            strassenZustand.predicate,
            jahr.predicate,
            monat.predicate,
            wochentag.predicate
            //                wochentag.predicate,
            //                land.predicate
        ].compactMap{$0}
    }

    var grdbFilters: [SQLExpression] {
        
        var expressions: [SQLExpression] = []

        if istPkw         != .keineAuswahl { expressions.append(istPkw         == .mitPkw         ? Column("vehicleMask") & VehicleMask.pkw.rawValue         != 0 : Column("vehicleMask") & VehicleMask.pkw.rawValue == 0) }
        if istFahrrad     != .keineAuswahl { expressions.append(istFahrrad     == .mitFahrrad     ? Column("vehicleMask") & VehicleMask.fahrrad.rawValue     != 0 : Column("vehicleMask") & VehicleMask.fahrrad.rawValue == 0)  }
        if istFussgaenger != .keineAuswahl { expressions.append(istFussgaenger == .mitFussgaenger ? Column("vehicleMask") & VehicleMask.fussgaenger.rawValue != 0 : Column("vehicleMask") & VehicleMask.fussgaenger.rawValue == 0)  }
        if istKrad        != .keineAuswahl { expressions.append(istKrad        == .mitKrad        ? Column("vehicleMask") & VehicleMask.krad.rawValue        != 0 : Column("vehicleMask") & VehicleMask.krad.rawValue == 0)  }
        if istGueterKfz   != .keineAuswahl { expressions.append(istGueterKfz   == .mitGueterKfz   ? Column("vehicleMask") & VehicleMask.gueterKfz.rawValue   != 0 : Column("vehicleMask") & VehicleMask.gueterKfz.rawValue == 0)  }
        if istSonstige    != .keineAuswahl { expressions.append(istSonstige    == .mitSonstige    ? Column("vehicleMask") & VehicleMask.sonstige.rawValue    != 0 : Column("vehicleMask") & VehicleMask.sonstige.rawValue == 0)  }

        // UND-Verknüpfung aller gesetzten Filter (AND-Kombination)
        let vehicleMaskFilter: SQLExpression?
        switch expressions.count {
        case 0: vehicleMaskFilter = nil
        case 1: vehicleMaskFilter = expressions.first
        default: vehicleMaskFilter = expressions.dropFirst().reduce(expressions.first!) { $0 && $1 }
        }
    
        return [ // Order with respect to highest number of different values.
            monat.grdbFilter,              // [0 ... 12]
            unfallArt.grdbFilter,          // [0 ... 10]
            jahr.grdbFilter,               // [0, 2016, ... 2023], 9 states
            unfallTyp1.grdbFilter,         // [0 ... 7]
            wochentag.grdbFilter,          // [0 ... 7]
            lichtVerhaeltnisse.grdbFilter, // [0, 1, 2, 4]
            strassenZustand.grdbFilter,    // [0, 1, 2, 4]
            unfallKategorie.grdbFilter,    // [0 ... 3]
            vehicleMaskFilter
        ].compactMap { $0 }
    }

}




@MainActor
final class ViewModel: ObservableObject {
    
    // static let countOfAllAccidents = 1_554_834 // with 2022 date. Value to be filled in by hand, whenever new data files for new years are added.
    // count of all accidents in the database when all the years are imported into the database
    static let totalCountinGermany = 1_823_882 // With 2023 data. Value to filled in by hand, whenever new data files for new years are added.
    
    // count of all accidents in the database if no filter/seletion is applied, otherwhise the count of the accidents in the database after filtering/selection
    @Published var selectedCountInGermany: Int = 0
    @Published var isFetchingSelectedCountInGermany = false
    private var taskForFetchCountInGermany: Task<Void, Error>? = nil

    // count of the subset of the accidents in the database that lies in the respective region (geographic rectangular), filter/selection applied.
    // Number is limited by fetchlimit, thus it can be a number from 0 up to fetchLimit.
//    @Published var totalCountInRegion: Int = 0
    @Published var selectedCountInRegion: Int = 0
    @Published var isFetchingSelectedCountInRegion = false
    private var taskForFetchCountInRegion: Task<Void, Error>? = nil

    // Accidents to be displayed, i.e. the accidents in the respective region (0 up to fetchLimit accidents)
//    @Published var accidentStructs: [AccidentStruct] = []
    @Published var accidentStructsGRDB: [AccidentStructGRDB] = []
    @Published var isFetchingAccidents = false
    @Published var accidentDataFilters = AccidentDataFilter()
    private var taskForFetchAccidents: Task<Void, Never>? = nil
    private(set) var fetchLimit = 400 //300 // Maximum number of accidents to fetched -> fetchLimit for fetch request.
    
//    private var fetchOperation: FetchOperation? = nil
    
    init(initFromFile: Bool = false) {
//        asyncContext.automaticallyMergesChangesFromParent = true
        
//        let didSaveNotification = NSManagedObjectContext.didSaveObjectsNotification
//        NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)), name: didSaveNotification, object: nil)
#if DEBUG
        print("Running in debug mode.")
#else
        print("Running in release mode.")
#endif
    }
    
    
    func clearAccidentsGRDB() {
        self.accidentStructsGRDB = []
    }
    
    
//    /// Called when context was saved. Updates the count of selected accidents in the respective view.
//    /// - Parameter notification: This parameter is not used
//    @objc func didSave(_ notification: Notification) {
////        getCountOfSelectedAccidents()
////        fetchCountInGermany()
//    }
  
    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
    func fetchAccidentsGRDB(region: MKCoordinateRegion) {
   
        taskForFetchAccidents?.cancel()
        taskForFetchAccidents = Task.detached(priority: .high) {
            
            await MainActor.run { self.isFetchingAccidents = true }
            let limit = await self.fetchLimit
            
            do {
                let box = region.boundingBox100
                let filters = await self.accidentDataFilters.grdbFilters
                let combinedFilter = filters.reduce(true.sqlExpression) { $0 && $1 }
                
                let rows = try await DatabaseService.shared.dbPool.read { db in

                    try AccidentNeu
                        .filter(Column("longitude100") >= box.minLon && Column("longitude100") <= box.maxLon)
                        .filter(Column("latitude100") >= box.minLat && Column("latitude100") <= box.maxLat)
                        .filter(combinedFilter)
                        .order(Column("id").asc)
                        .limit(limit)
                        .fetchAll(db)
                }

                let accidentStructsGDRB = rows.map(AccidentStructGRDB.init) // Creates AccidentStrucGRDB for every record from the record and puts into result array

                await Task.yield()
                
                await MainActor.run {
                    self.accidentStructsGRDB = accidentStructsGDRB
                    self.isFetchingAccidents = false
                    print("🧪 fetched \(rows.count) accidents.")
                }
            } catch {
                await MainActor.run { self.isFetchingAccidents = false }
                print("❌ Fehler beim GRDB-Fetch fetchAccidentsGRDB: \(error)")
            }
        }
    }
    
    func fetchCountInRegion(region: MKCoordinateRegion) {
   
        taskForFetchCountInRegion?.cancel()
        taskForFetchCountInRegion = Task.detached(priority: .high) {
            
            await MainActor.run { self.isFetchingSelectedCountInRegion = true }
            
            do {
                let box = region.boundingBox100
                let filters = await self.accidentDataFilters.grdbFilters
                let combinedFilter = filters.reduce(true.sqlExpression) { $0 && $1 }
                
                let count = try await DatabaseService.shared.dbPool.read { db in

                    try AccidentNeu
                        .filter(Column("longitude100") >= box.minLon && Column("longitude100") <= box.maxLon)
                        .filter(Column("latitude100") >= box.minLat && Column("latitude100") <= box.maxLat)
                        .filter(combinedFilter)
                        .fetchCount(db)
                }
                
                await Task.yield()

                await MainActor.run {
                    self.selectedCountInRegion = count
                    self.isFetchingSelectedCountInRegion = false
                    print("🧪 fetched count in region: \(count).")
                }
            } catch {
                await MainActor.run { self.isFetchingAccidents = false }
                print("❌ Fehler beim GRDB-Fetch fetchCountInRegion: \(error)")
            }
        }
    }
    
    
    func fetchCountInGermany() {
        
//        isFetchingSelectedCountInGermany = true
//        selectedCountInGermany = 0
        
        taskForFetchCountInGermany?.cancel()
        taskForFetchCountInGermany = Task.detached(priority: .high) {

            await MainActor.run {
                self.selectedCountInGermany = 0
                self.isFetchingSelectedCountInGermany = true
            }

            do {
                let filters = await self.accidentDataFilters.grdbFilters
                let combinedFilter = filters.reduce(true.sqlExpression) { $0 && $1 }
                
                let count = try await DatabaseService.shared.dbPool.read { db in
                    try AccidentNeu
                        .filter(combinedFilter)
                        .order(Column("id").asc)
                        .fetchCount(db)
                }
                
                await Task.yield()

                await MainActor.run {
                    self.selectedCountInGermany = count
                    self.isFetchingSelectedCountInGermany = false
                    print("🧪 fetched count in Germany: \(count).")
                }
            } catch {
                await MainActor.run { self.isFetchingAccidents = false }
                print("❌ Fehler beim GRDB-Fetch fetchCountInGermany: \(error)")
            }
        }
    }
 
//    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
//    func fetchAccidents(region: MKCoordinateRegion)  {
//        
//        // Detached task does NOT run on the main thread and needs to be called with await.
//        taskForFetchAccidents?.cancel()
//        taskForFetchAccidents = Task.detached(priority: .high) {
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
////                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newCountPredicate] + [region.predicate])
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newCountPredicate] + [region.predicateForRegion()])
////                request.predicate = region.predicateForRegion()
//            } else {
////                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicate] + predicates)
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [region.predicateForRegion()] + predicates)
//            }
//            
//            // Sortdescriptors
//            // brings in some distribution of the results in the region, otherwhise only accidents at the lower edge of the region are fetched
//            //                request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.accidentObjectID, ascending: true)]
//            request.sortDescriptors = [NSSortDescriptor(keyPath: \Accident.objectID, ascending: true)]
//            
//            if Task.isCancelled {
////                print("------Task is cancelled in new fetchAccidents 0 ----------")
//                return
//            }
//            
//            // Background context and execution of fetch request
//            let newContext = PersistenceController.shared.container.newBackgroundContext()
//            var accidents: [Accident] = []
//            var accidentStructs: [AccidentStruct] = []
//            try? newContext.performAndWait {
////                print("Im Context")
//                accidents =  try newContext.fetch(request)
//                
//                for accident in accidents {
//                    accidentStructs.append(
//                        AccidentStruct(
//                            id: accident.objectID,
//                            accidentObjectID: accident.accidentObjectID,
//                            vehicleMask: accident.vehicleMask,
//
//                            jahr: accident.jahr,
////                            land: accident.land,
//                            latitude: accident.latitude,
//                            lichtVerhaeltnisse: accident.lichtVerhaeltnisse,
//                            longitude: accident.longitude,
//                            monat: accident.monat,
//                            strassenZustand: accident.strassenZustand,
//                            stunde: accident.stunde,
//                            unfallArt: accident.unfallArt,
//                            unfallKategorie: accident.unfallKategorie,
//                            unfallTyp1: accident.unfallTyp1,
//                            wochentag: accident.wochentag,
//                            coordinate: accident.coordinate,
//                            color: accident.color
//                        )
//                    )
//                }
//            }
//            
//            if Task.isCancelled {
////                print("------Task is cancelled in new fetchAccidents 1 ----------")
//                return
//            }
//            
//            Task { @MainActor [unowned self, accidentStructs ] in
//                self.accidentStructs = accidentStructs
////                print("Count of accidents is: \(accidentStructs.count)")
//
//                self.isFetchingAccidents = false
//            }
//            
////            await print("AccidentDataFilters.predicates: \(self.accidentDataFilters.predicates)")
//        }
//    }
//
//    
//    func getCountOfSelectedAccidents() {
//        
//        isFetchingSelectedCountInGermany = true
//
//        taskForFetchCountInGermany?.cancel()
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Accident")
//        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates)
//        fetchRequest.resultType = .countResultType
//
//        fetchOperation?.cancel()
//        fetchOperation = performFetchRequest(fetchRequest: fetchRequest)
//
//        // Task needed for polling the results from the fetch operation
//        taskForFetchCountInGermany = Task {
//            // Do something
//
//            while true {
//                guard !Task.isCancelled else {
////                    print("I task was cancelled")
//                    break
//                }
//                if let fetchOperation, fetchOperation.isCancelled {
////                    print("fetchOperation cancelled")
//                    break
//                }
//                if let fetchOperation, fetchOperation.isFinished {
////                    print("fetchOperation finished")
//                    isFetchingSelectedCountInGermany = false
//                    selectedCountInGermany = fetchOperation.count ?? 0
////                    print("# of accidents: \(countOfSelectedAccidents)")
//                    break
//                }
////                print("I will wail a little bit...")
//
//                try await Task.sleep(nanoseconds: 100_000_000) // Polling every 100 ms
//            }
////            print("I will return...")
//            return
//        }
//    }
//    
//    
//    /// Loads the count of selected accidents for the current selection (i.e. filters set)from the database.
//    /// This is for whole Germany, dependent on e.g. day/night, type of accident et Cetera. It is independent of the region, but always for whole Germany.
//    /// Uses Operation. Operations can be cancelled and thus a running fetch request on that operation will be cancelled together with this operation.
//    /// Changed to this version due to Swift 6.
//    func performFetchRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> FetchOperation {
//
//        let context = PersistenceController.shared.container.newBackgroundContext()
//        let fetchOperation = FetchOperation(context: context, fetchRequest: fetchRequest)
//
//        let operationQueue = OperationQueue()
//        operationQueue.addOperation(fetchOperation)
//
//        return fetchOperation
//    }
//    
    

}


///// Creates an Operation and runs a fetch request on it.
///// If the result type is .countType, then the count property will be filled with the count of respective objects in the database.
/////
///// Advantage is that the operation can be cancelled and with the cancellation the (possibly long running) fetch request will be cancelled, too. Furthermore, this runs on a background thread and the UI remains responsive.
/////
///// Disadvantage is that the results "appear" after some time (during that the operation can be cancelled). Thus, polling has to be implemented until the results are available (operation finshed) or the operation is cancelled.
//class FetchOperation: Operation, @unchecked Sendable {
//
//    /// The managed object context for the fetch request
//    private let context: NSManagedObjectContext
//    /// The fetch request
//    private let fetchRequest: NSFetchRequest<NSFetchRequestResult>
//    /// The count of the objects in the data base, if the fetch request was successfull, otherwhise nil.
//    var count: Int? = nil
//    var accidentStructs: [AccidentStruct] = []
//
//    init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
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
//                let result = try context.fetch(fetchRequest)
//                if !self.isCancelled {
//                    // Make use of the results
//                    if let result = result as? [NSNumber] {
//                        self.count = result.first?.intValue
//                    } else if let accidents = result as? [Accident] {
//                        for accident in accidents {
//                            self.accidentStructs.append(
//                                AccidentStruct(
//                                    id: accident.objectID,
//                                    accidentObjectID: accident.accidentObjectID,
//                                    vehicleMask: accident.vehicleMask,
//                                    jahr: accident.jahr,
////                                    land: accident.land,
//                                    latitude: accident.latitude,
//                                    lichtVerhaeltnisse: accident.lichtVerhaeltnisse,
//                                    longitude: accident.longitude,
//                                    monat: accident.monat,
//                                    strassenZustand: accident.strassenZustand,
//                                    stunde: accident.stunde,
//                                    unfallArt: accident.unfallArt,
//                                    unfallKategorie: accident.unfallKategorie,
//                                    unfallTyp1: accident.unfallTyp1,
//                                    wochentag: accident.wochentag,
//                                    coordinate: accident.coordinate,
//                                    color: accident.color
//                                )
//                            )
//                        }
//                        
//                        self.count = result.count
//                    }
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


