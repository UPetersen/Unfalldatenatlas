//
//  ContentView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 13.01.23.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocationUI


struct VeganFoodPlace: Identifiable {
  var id = UUID()
  let name: String
  let latitude: Double
  let longitude: Double

  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var showSymbols = false
    
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)], animation: .default) private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.accidents) { accident in
                MapAnnotation(coordinate: accident.coordinate) {
                        ZStack {
                            if showSymbols {
                                Circle().stroke(colorForAccidentType1(accident: accident), lineWidth: 5)
                                    .frame(width: 25, height: 25)
                                Text("\(accident.jahr - 2000)\(symbolsForAccident(accident: accident))").font(.title3)
                            } else {
                                Circle().stroke(colorForAccidentType1(accident: accident), lineWidth: 5)
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                }
                // fetch accidents for current region only some time after user does not pan or pinch anymore.
                .onReceive(viewModel.$region.debounce(for: 0.25, scheduler: RunLoop.main)) {
                    _ in viewModel.fetchTheAccidents(region: viewModel.region)
                }
//                .ignoresSafeArea()
                HStack {
                    Text("\(viewModel.accidents.count) von \(viewModel.countOfAllAccidents) Unfällen")
                        .padding(.horizontal)
                    Spacer()
                    Text("Span: \(viewModel.region.span.latitudeDelta), \(viewModel.region.span.longitudeDelta)")
                }
            }
            .onTapGesture {
//                viewModel.showSymbols.toggle()
                showSymbols.toggle()
            }
            .onAppear() {
                viewModel.importFromFiles()
    //            viewModel.fetchTheAccidents(region: viewModel.region)
                print("Ende .onAppear")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        FilterView(accidentDataFilters: self.$viewModel.accidentDataFilters)
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
    
    
    func symbolsForAccident(accident: Accident) -> String {
        var symbol = ""
        
        // Type of vehicles/persones involved. https://www.destatis.de/DE/ Themen/Gesellschaft- Umwelt/Verkehrsunfaelle/M ethoden/_inhalt.html#sprg37 1798
        if accident.istPkw { symbol.append("🚗") }
        if accident.istKrad { symbol.append("🏍️") }
        if accident.istFahrrad { symbol.append("🚴") }
        if accident.istFussgaenger { symbol.append("🚶‍♂️") }
        // Güterkraffahrzeuge: Unfall mit Güterkraftfahrzeug (GKFZ): Unfall, an dem mindestens ein Lastkraftwagen mit
        // Normalaufbau und einem Gesamtgewicht über 3,5 t, ein Lastkraftwagen mit Tankauflage bzw. Spezialaufbau,
        // eine Sattelzugmaschine oder eine andere Zugmaschine beteiligt war (diese Kategorie ist in
        // den Jahren 2016 und 2017 in "Unfall mit Sonstigen" enthalten)
        if accident.istGueterKfz { symbol.append("🚚") }
        // Unfall mit Sonstigen: Unfall, an dem mindestens ein oben nicht genanntes Verkehrsmittel beteiligt war, wie
        // z. B. ein Bus oder eine Straßenbahn (2016 und 2017 einschließlich Unfall mit Güterkraftfahrzeug (GKFZ),
        // ab 2018 ohne Unfall mit GKFZ)
        if accident.istSonstige {
            if accident.jahr >= 2018 {
                symbol.append("🚌/🚃")
            } else {
                symbol.append("🚚/🚌/🚃")
            }
        }
        
        // Light Conditions, not icon for twilight (Dämmerung) available, so just made it night, too.
        if accident.lichtVerhaeltnisse >= 1 {symbol.append("🌝") }
        
        // Road conditions
        if accident.strassenZustand == 1 {
            symbol.append("🌧️")
        } else if accident.strassenZustand == 2 {
            symbol.append("❄️")
        }
        
        //Accident Category (Unfallkategorie): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        switch accident.unfallKategorie {
        case 1: symbol.append("✟")
        case 2: symbol.append("🏥")
        case 3: symbol.append("🩹")
        default: fatalError("Wrong Unfallkategorie: \(accident.unfallKategorie). Must be 1, 2 or 3.")
        }
     
        // Accident kind (Unfallart): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Zusammenstoß mit anfahrendem/ anhaltendem/ruhendem Fahrzeug
        // 2 = Zusammenstoß mit vorausfahrendem / wartendem Fahrzeug
        // 3 = Zusammenstoß mit seitlich in gleicher Richtung fahrendem Fahrzeug
        // 4 = Zusammenstoß mit entgegenkommendem Fahrzeug
        // 5 = Zusammenstoß mit einbiegendem / kreuzendem Fahrzeug
        // 6 = Zusammenstoß zwischen Fahrzeug und Fußgänger
        // 7 = Aufprall auf Fahrbahnhindernis
        // 8 = Abkommen von Fahrbahn nach rechts
        // 9 = Abkommen von Fahrbahn nach links Unfall
        // 0 = anderer Art
        symbol.append("A\(accident.unfallArt)")
        
        // Accident type (Unfalltyp1): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Fahrunfall
        // 2 = Abbiegeunfall
        // 3 = Einbiegen / Kreuzen-Unfall
        // 4 = Überschreiten-Unfall
        // 5 = Unfall durch ruhenden Verkehr
        // 6 = Unfall im Längsverkehr
        // 7 = sonstiger Unfall
        symbol.append("T\(accident.unfallTyp1)")
        
        return symbol
    }
    
    /// Returns the color to use for Unfall Type 1, as of https://de.wikipedia.org/wiki/Unfalltyp
    func colorForAccidentType1(accident: Accident) -> Color {
        switch accident.unfallTyp1 {
        case 1: return Color.green   // 1 = Fahrunfall
        case 2: return Color.yellow  // 2 = Abbiegeunfall
        case 3: return Color.red     // 3 = Einbiegen / Kreuzen-Unfall
        case 4: return Color.white   // 4 = Überschreiten-Unfall
        case 5: return Color.blue    // 5 = Unfall durch ruhenden Verkehr
        case 6: return Color.orange  // 6 = Unfall im Längsverkehr
        case 7: return Color.black   // 7 = sonstiger Unfall
        default:
            fatalError("Wrong Unfalltyp 1: \(accident.unfallTyp1). Must be one out of 1 to 7.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var viewModel = ViewModel()
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
