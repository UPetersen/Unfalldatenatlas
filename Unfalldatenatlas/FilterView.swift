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
    
    @State private var task: Task<Void, Never>? = nil
    
    
    var body: some View {
        
        List {
            
            Section(header: Text("Ausgewählte Unfälle in der Datenbank")) {
                HStack {
                    Text("Anzahl Unfälle:")
                    Spacer()
                    CountOfSelectedAccidentsView(countOfSelectedAccidents: viewModel.countOfSelectedAccidents, isFetchingCountOfSelectedAccidents: isFetchingCountOfSelectedAccidents)
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
            isFetchingCountOfSelectedAccidents = true
            task?.cancel()
            task = Task {
                await viewModel.fetchCountOfSelectedAccidents()
                if Task.isCancelled {
                    print("------Task fetchCountOfSelectedAccidents is cancelled in FilterView ----------")
                    return
                }

                isFetchingCountOfSelectedAccidents = false
            }
        }
    }
}


//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView()
//    }
//}
