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
            land.grdbFilter,               // [0 ... 15]
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

///// Represents the status of an async fetch operation (e.g. loading, success, failure).
//enum FetchStatus {
//    case idle        // No task running
//    case fetching    // Task is currently fetching
//    case success     // Fetch finished successfully
//    case failure     // Fetch failed
//}


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
        self.isFetchingAccidents = true
        self.isFetchingSelectedCountInRegion = true
    }
    
    
    //    /// Called when context was saved. Updates the count of selected accidents in the respective view.
    //    /// - Parameter notification: This parameter is not used
    //    @objc func didSave(_ notification: Notification) {
    ////        getCountOfSelectedAccidents()
    ////        fetchCountInGermany()
    //    }
    
    /// Loads accidents for the current region from the database. This is ASYNC! since it is called from .task, mainly when user
    func fetchAccidentsGRDB(region: MKCoordinateRegion) {
        
         self.isFetchingAccidents = true
        
        taskForFetchAccidents?.cancel()
        taskForFetchAccidents = Task.detached(priority: .high) {
            
            if Task.isCancelled {print("Task cancelled in fetchAccidentsGRDB 0"); return }

            
            let dateStart = Date()
            // Nachfolgende Zeile verursacht Flackern im UI. Das UI wird trotzdem dies auskodierr ist immer wieder gerendert und die Accidents neu gefetched.
            let limit = await self.fetchLimit
            
            do {
                let box = region.boundingBox100
                let filters = await self.accidentDataFilters.grdbFilters
                let combinedFilter = filters.reduce(true.sqlExpression) { $0 && $1 }
                
                let rows = try await DatabaseService.shared.dbPool.read { db in
                    
//                    try AccidentNeu
//                        .filter(Column("longitude100") >= box.minLon && Column("longitude100") <= box.maxLon)
//                        .filter(Column("latitude100") >= box.minLat && Column("latitude100") <= box.maxLat)
//                        .filter(combinedFilter)
//                        .order(Column("id").asc)
//                        .limit(limit)
//                        .fetchAll(db)
                    try AccidentStructGRDB
                        .select(
                            Column("id"),
                            Column("vehicleMask"),
                            Column("jahr"),
                            Column("latitude100"),
                            Column("longitude100"),
                            Column("lichtVerhaeltnisse"),
                            Column("monat"),
                            Column("strassenZustand"),
                            Column("stunde"),
                            Column("unfallArt"),
                            Column("unfallKategorie"),
                            Column("unfallTyp1"),
                            Column("wochentag")
                        )
                        .filter(Column("longitude100") >= box.minLon && Column("longitude100") <= box.maxLon)
                        .filter(Column("latitude100") >= box.minLat && Column("latitude100") <= box.maxLat)
                        .filter(combinedFilter)
                        .order(Column("id").asc)
                        .limit(limit)
                        .fetchAll(db)
                }
                if Task.isCancelled {print("Task cancelled in fetchAccidentsGRDB 1"); return }
                
//                let accidentStructsGDRB = rows.map(AccidentStructGRDB.init) // Creates AccidentStrucGRDB for every record from the record and puts into result array
                
                await Task.yield()
                
                if Task.isCancelled {print("Task cancelled in fetchAccidentsGRDB 2"); return }
                
//                try? await Task.sleep(nanoseconds: 400_000_000) // Delay (debounce) for some time

                await MainActor.run {
//                    self.accidentStructsGRDB = accidentStructsGDRB
                    self.accidentStructsGRDB = rows
                    self.isFetchingAccidents = false
                    print(String(format: "🧪 fetched %d accidents in region in %.2f seconds.", rows.count, Date().timeIntervalSince(dateStart)))
                }
            } catch is CancellationError {
                print("❌ Abbruch duch cancel beim GRDB-Fetch fetchAccidentsGRDB.")
           } catch {
                print("❌ Fehler beim GRDB-Fetch fetchAccidentsGRDB: \(error)")
            }
        }
    }
    
    /// Fetches the number of accidents in the current map region.
    /// Runs in a detached Task to ensure parallelism with accident fetching.
    /// The result is stored in `selectedCountInRegion`, and fetch status is updated accordingly.
    func fetchCountInRegion(region: MKCoordinateRegion) {
        
        self.isFetchingSelectedCountInRegion = true

        taskForFetchCountInRegion?.cancel()
        taskForFetchCountInRegion = Task.detached(priority: .high) {
            
            if Task.isCancelled {print("Task cancelled in fetchCountInRegion, returning early 0."); return }

            
//            await MainActor.run { self.isFetchingSelectedCountInRegion = true }
            // Start fetch – set loading state
            let dateStart = Date()
            
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
                if Task.isCancelled {print("Task cancelled in fetchCountInRegion, returning early 1. Count would be \(count)"); return }

                
                await Task.yield()

                if Task.isCancelled {print("Task cancelled in fetchCountInRegion, returning early 2. Count would be \(count)"); return }

//                try? await Task.sleep(nanoseconds: 400_000_000) // Delay (debounce) for some time
                
                await MainActor.run {
                    self.selectedCountInRegion = count
                    self.isFetchingSelectedCountInRegion = false
                    print(String(format: "🧪 fetched count of %d accidents in region in %.2f seconds.",  count , Date().timeIntervalSince(dateStart)))
                }
            } catch is CancellationError {
                print("❌ Abbruch duch cancel beim GRDB-Fetch fetchCountInRegion.")
            } catch {
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
            } catch is CancellationError {
                print("❌ Abbruch duch cancel beim GRDB-Fetch fetchCountInGermany.")
            } catch {
                await MainActor.run { self.isFetchingSelectedCountInGermany = false }
                print("❌ Fehler beim GRDB-Fetch fetchCountInGermany: \(error)")
            }
        }
    }
}

