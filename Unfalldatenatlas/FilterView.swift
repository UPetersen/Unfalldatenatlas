//
//  FilterView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 01.02.23.
//

import SwiftUI
import MapKit

struct FilterView: View {
    
    @Environment(\.colorScheme) var colorScheme // .dark for dark mode
    @Environment(\.dismiss) var dismiss
    
    
    @ObservedObject var viewModel: ViewModel
    @Binding var accidentDataFilters: AccidentDataFilter
    @Binding var isFetchingCountOfSelectedAccidents: Bool
    var displayPercentage: Bool
    
//    @State private var task: Task<Void, Never>? = nil
//    @State private var backgroundContext = PersistenceController.shared.container.newBackgroundContext()
//    @State private var fetchOperation: FetchOperationForCountFetchRequest? = nil
//    @State private var task2: Task<Void, Error>? = nil
    
    var body: some View {
        
        List {
            
            Section(header: Text("Ausgewählte Unfälle in der Datenbank")) {
                HStack {
                    Text("Anzahl Unfälle:")
                    Spacer()
                    CountOfSelectedAccidentsView(countOfAllAccidents: ViewModel.countOfAllAccidents, countOfSelectedAccidents: viewModel.countOfSelectedAccidents, isFetchingCountOfSelectedAccidents: viewModel.isFetchingCountOfSelectedAccidents, displayPercentage: displayPercentage)
                }
            }
            
            Section(header: Text("Unfallmerkmale")) {
                // Unfall-Kategorie
                Picker("Unfall-Kategorie", selection: $accidentDataFilters.unfallKategorie) {
                    ForEach(UnfallKategorie.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Unfall-Art
                Picker("Unfall-Art", selection: $accidentDataFilters.unfallArt) {
                    ForEach(UnfallArt.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Unfall-Typ
                Picker("Unfall-Typ", selection: $accidentDataFilters.unfallTyp1) {
                    ForEach(UnfallTyp1.allCases, id: \.id) { $0.sectionTextView(colorScheme: colorScheme).tag($0) }
                }
            }
            
            Section(header: Text("Umgebungsbedingungen")) {
                // Lichtverhaeltnisse
                Picker("Lichtverhältnisse", selection: $accidentDataFilters.lichtVerhaeltnisse) {
                    ForEach(LichtVerhaeltnisse.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Strassenzustand
                Picker("Straßenzustand", selection: $accidentDataFilters.strassenZustand) {
                    ForEach(StrassenZustand.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
            }
            
            Section(header: Text("Verkehrsteilnehmer")) {
                // Pkw-Beteiligung
                Picker("Pkwbeteiligung", selection: $accidentDataFilters.istPkw) {
                    ForEach(IstPkw.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Krad-Beteiligung
                Picker("Kraftradbeteiligung", selection: $accidentDataFilters.istKrad) {
                    ForEach(IstKrad.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Fahrrad-Beteiligung
                Picker("Fahrradbeteiligung", selection: $accidentDataFilters.istFahrrad) {
                    ForEach(IstFahrrad.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Fußgänger-Beteiligung
                Picker("Fußgängerbeteiligung", selection: $accidentDataFilters.istFussgaenger) {
                    ForEach(IstFussgaenger.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Güter-Kfz-Beteiligung
                Picker("Güter-Kfz-Beteiligung", selection: $accidentDataFilters.istGueterKfz) {
                    ForEach(IstGueterKfz.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Sonstige-Kfz-Beteiligung
                Picker("Sonstige Kfz-Beteiligung", selection: $accidentDataFilters.istSonstige) {
                    ForEach(IstSonstige.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
            }
            
            Section(header: Text("Datum/Zeit")) {
                // Unfall-Jahr
                Picker("Unfall-Jahr", selection: $accidentDataFilters.jahr) {
                    ForEach(UnfallJahr.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Unfall-Monat
                Picker("Unfall-Monat", selection: $accidentDataFilters.monat) {
                    ForEach(UnfallMonat.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                
                // Unfall-Wochentag
                Picker("Unfall-Wochentag", selection: $accidentDataFilters.wochentag) {
                    ForEach(UnfallWochentag.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
            }
            
            Section(header: Text("Örtlichkeit")) {
                // Bundesland
                Picker("Bundesland", selection: $accidentDataFilters.land) {
                    ForEach(Land.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
            }
#if DEBUG
            Section(header: Text("Filterbedingung (Debugging)")) {
                Text("Filter: \(accidentDataFilters.predicates.debugDescription)")
            }
#endif
            
        }
        
        // TOP BAR with title and "Fertig" Button
        .safeAreaInset(edge: .top) {
            HStack {
                Button("Fertig", action: { dismiss() }).hidden()
                    .padding(.horizontal)
                Spacer()
                Text("Datenauswahl")
                    .font(Font.title)
                Spacer()
                Button("Fertig", action: { dismiss() })
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        //        .navigationTitle("Datenauswahl")
        
        // Whenever the flter/selections changes, then update count of selected accidents and the corresponding accidents in the region.
        .onChange(of: viewModel.accidentDataFilters) {
            print("----------------- in .onChange (FilterView) due to init or accidentDataFilters change -------------------")
            
            viewModel.getCountOfSelectedAccidents()

//            isFetchingCountOfSelectedAccidents = true
//            let hugo = 4
//            if hugo == 1 { // As implemented in first version of distributed app
//                task?.cancel()
//                task = Task {
//                    await viewModel.fetchCountOfSelectedAccidents()
//                    DispatchQueue.main.async {
//                        isFetchingCountOfSelectedAccidents = false
//                    }
//                }
//            } else if hugo == 2 { // intermediate test version
//                task?.cancel()
//                task = Task.detached(priority: .high) {
//                    await viewModel.fetchCountOfSelectedAccidents3()
//                    DispatchQueue.main.async {
//                        isFetchingCountOfSelectedAccidents = false
//                    }
//                    if Task.isCancelled {
//                        print("------Task fetchCountOfSelectedAccidents is cancelled in FilterView ----------")
//                        return
//                    }
//                }
//            } else if hugo == 3 { // Version that uses operations, which can be cancelled directly
//                
//                task2?.cancel()
//                fetchOperation?.cancel()
//                fetchOperation = viewModel.performCountFetchRequest(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: accidentDataFilters.predicates))
//
//                // Task needed for polling the results from the fetch operation
//                task2 = Task {
//                    // Do something
//
//                    while true {
//                        guard !Task.isCancelled else {
//                            print("I task was cancelled")
//                            break
//                        }
//                        if let fetchOperation, fetchOperation.isCancelled {
//                            print("fetchOperation cancelled")
//                            break
//                        }
//                        if let fetchOperation, fetchOperation.isFinished {
//                            print("fetchOperation finished")
//                            isFetchingCountOfSelectedAccidents = false
//                            viewModel.countOfSelectedAccidents = fetchOperation.count ?? 0
//                            print("# of accidents: \(viewModel.countOfSelectedAccidents)")
//                            break
//                        }
//                        print("I will wail a little bit...")
//
//                        try await Task.sleep(nanoseconds: 100_000_000) // Polling every 100 ms
//                    }
//                    print("I will return...")
//                    return
//                }
//
//            } else {
//                viewModel.countOfSelectedAccidents()
//            }


        }
    }
}


//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView()
//    }
//}

