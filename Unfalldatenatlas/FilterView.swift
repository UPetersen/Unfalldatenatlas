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

    @ObservedObject var viewModel: ViewModel
    @Binding var accidentDataFilters: AccidentDataFilter
    var theRegion: MKCoordinateRegion

    private let debounceTime = 0.1
    
    var body: some View {
        List {

            Section {
                HStack {
                    Text("Anzahl Unfälle:")
                    Spacer()
                    Text("\(viewModel.countOfAllAccidents)")
                }
            }

            Section {
                // Unfall-Kategorie
                Picker("Unfall-Kategorie", selection: $accidentDataFilters.unfallKategorie) {
                    ForEach(UnfallKategorie.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.unfallKategorie , debounceTime: debounceTime) { _ in updateMapView() }

                
                // Unfall-Art
                Picker("Unfall-Art", selection: $accidentDataFilters.unfallArt) {
                    ForEach(UnfallArt.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.unfallArt , debounceTime: debounceTime) { _ in updateMapView() }

                // Unfall-Typ
//                Picker("Unfall-Typ", selection: $accidentDataFilters.unfallTyp1) {
//                    ForEach(UnfallTyp1.allCases, id: \.id) { Text($0.sectionText).tag($0) }
//                }
                Picker("Unfall-Typ", selection: $accidentDataFilters.unfallTyp1) {
                    ForEach(UnfallTyp1.allCases, id: \.id) { $0.sectionTextView(colorScheme: colorScheme).tag($0) }
                }
                .onChange(of: accidentDataFilters.unfallTyp1 , debounceTime: debounceTime) { _ in updateMapView() }
            }
            
            Section {
                // Lichtverhaeltnisse
                Picker("Lichtverhälntisse", selection: $accidentDataFilters.lichtVerhaeltnisse) {
                    ForEach(LichtVerhaeltnisse.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.lichtVerhaeltnisse , debounceTime: debounceTime) { _ in updateMapView() }


                // Strassenzustand
                Picker("Straßenzustand", selection: $accidentDataFilters.strassenZustand) {
                    ForEach(StrassenZustand.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.strassenZustand , debounceTime: debounceTime) { _ in updateMapView() }
            }
            
            Section {
                // Pkw-Beteiligung
                Picker("Pkwbeteiligung", selection: $accidentDataFilters.istPkw) {
                    ForEach(IstPkw.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.istPkw , debounceTime: debounceTime) { _ in updateMapView() }

                
                // Krad-Beteiligung
                Picker("Kraftradbeteiligung", selection: $accidentDataFilters.istKrad) {
                    ForEach(IstKrad.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.istKrad , debounceTime: debounceTime) { _ in updateMapView() }

                
                // Fahrrad-Beteiligung
                Picker("Fahrradbeteiligung", selection: $accidentDataFilters.istFahrrad) {
                    ForEach(IstFahrrad.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.istFahrrad , debounceTime: debounceTime) { _ in updateMapView() }

                
                // Fußgänger-Beteiligung
                Picker("Fußgängerbeteiligung", selection: $accidentDataFilters.istFussgaenger) {
                    ForEach(IstFussgaenger.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.istFussgaenger , debounceTime: debounceTime) { _ in updateMapView() }

                //            .onChange(of: accidentDataFilters.istFussgaenger) { predicates.istFussgaenger = $0.predicate }
                
                // Güter-Kfz-Beteiligung
                Picker("Güter-Kfz-Beteiligung", selection: $accidentDataFilters.istGueterKfz) {
                    ForEach(IstGueterKfz.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.istGueterKfz , debounceTime: debounceTime) { _ in updateMapView() }

                
                // Sonstige-Kfz-Beteiligung
                Picker("Sonstige Kfz-Beteiligung", selection: $accidentDataFilters.istSonstige) {
                    ForEach(IstSonstige.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.istSonstige , debounceTime: debounceTime) { _ in updateMapView() }

            }
            
            Section {
                // Unfall-Jahr
                Picker("Unfall-Jahr", selection: $accidentDataFilters.jahr) {
                    ForEach(UnfallJahr.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.jahr , debounceTime: debounceTime) { _ in updateMapView() }


                // Unfall-Monat
                Picker("Unfall-Monat", selection: $accidentDataFilters.monat) {
                    ForEach(UnfallMonat.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.monat , debounceTime: debounceTime) { _ in updateMapView() }


                // Unfall-Wochentag
                Picker("Unfall-Wochentag", selection: $accidentDataFilters.wochentag) {
                    ForEach(UnfallWochentag.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.wochentag , debounceTime: debounceTime) { _ in updateMapView() }

            }

            Section {
                // Bundesland
                Picker("Bundesland", selection: $accidentDataFilters.land) {
                    ForEach(Land.allCases, id: \.id) { Text($0.sectionText).tag($0) }
                }
                .onChange(of: accidentDataFilters.land , debounceTime: debounceTime) { _ in updateMapView() }
            }
            
            Section {
                Text("Filter: \(accidentDataFilters.predicates.debugDescription)")
            }

        }
        .navigationTitle("Datenauswahl")
    }
    
    func updateMapView() {
//        viewModel.fetchTheAccidents(region: theRegion)
        viewModel.fetchTheAccidents()
    }
}

enum Land: Int, Identifiable, CaseIterable {
    case keineAuswahl = 0
    case schleswigHolstein = 1
    case hamburg = 2
    case niedersachsen = 3
    case bremen = 4
    case nordrheinWestphalen = 5
    case hessen = 6
    case rheinlandPfalz = 7
    case badenWuerttemberg = 8
    case bayern = 9
    case saarland = 10
    case berlin = 11
    case brandenburg = 12
    case mecklenburgVorpommern = 13
    case sachsen = 14
    case sachsenAnhalt = 15
    case thueringen = 16
    
    var id: Self { self }
    
    var setWithAllCases: Set<Land> {
        return Set(Self.allCases)
    }

    
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "land == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .schleswigHolstein: return "Schleswig-Holstein (ab 2016)"
        case .hamburg: return "Hamburg (ab 2016)"
        case .niedersachsen: return "Niedersachsen (ab 2017)"
        case .bremen: return "Bremen (ab 2016)"
        case .nordrheinWestphalen: return "Nordrhein-Westphalen (ab 2016)"
        case .hessen: return "Hessen (ab 2016)"
        case .rheinlandPfalz: return "Rheinland-Pfalz (ab 2017)"
        case .badenWuerttemberg: return "Baden-Württemberg (ab 2016)"
        case .bayern: return "Bayern (ab 2016)"
        case .saarland: return "Saarland (ab 2017)"
        case .berlin: return "Berlin (ab 2018)"
        case .brandenburg: return "Brandenburg (ab 2017)"
        case .mecklenburgVorpommern: return "Mecklenburg-Vorpommern (ab 2020)"
        case .sachsen: return "Sachsen (ab 2016)"
        case .sachsenAnhalt: return "Sachsen-Anhalt (ab 2017)"
        case .thueringen: return "Thürungen (ab 2019)"
        }
    }
}


enum StrassenZustand: Int, Identifiable, CaseIterable {
    case keineAuswahl = 4
    case trocken = 0
    case nassFeuchtSchluepfrig = 1
    case winterglatt = 2
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "strassenZustand == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .trocken: return "Trocken"
        case .nassFeuchtSchluepfrig: return "Nass/feucht/schlüpfrig 🌧️"
        case .winterglatt: return "Winterglatt ❄️"
        }
    }
}

enum LichtVerhaeltnisse: Int, Identifiable, CaseIterable {
    case keineAuswahl = 4
    case tageslicht = 0
    case daemmerung = 1
    case dunkelheit = 2
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "lichtVerhaeltnisse == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .tageslicht: return "Tageslicht"
        case .daemmerung: return "Dämmerung🌛"
        case .dunkelheit: return "Dunkelheit🌛"
        }
    }
}

enum UnfallWochentag: Int, Identifiable, CaseIterable {
    case keineAuswahl = 0
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "wochentag == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .sunday: return "Sonntag"
        case .monday: return "Montag"
        case .tuesday: return "Dienstag"
        case .wednesday: return "Mittwoch"
        case .thursday: return "Donnerstag"
        case .friday: return "Freitag"
        case .saturday: return "Samstag"
        }
    }
}

enum UnfallMonat: Int, Identifiable, CaseIterable {
    case keineAuswahl = 0
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "monat == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .january: return "Januar"
        case .february: return "Februar"
        case .march: return "März"
        case .april: return "April"
        case .may: return "Mai"
        case .june: return "Juni"
        case .july: return " Juli"
        case .august: return "August"
        case .september: return "September"
        case .october: return "Oktober"
        case .november: return "November"
        case .december: return "Dezember"
        }
    }
}



enum UnfallJahr: Int, Identifiable, CaseIterable {
    case keineAuswahl = 0
    case jahr2016 = 2016
    case jahr2017 = 2107
    case jahr2018 = 2018
    case jahr2019 = 2019
    case jahr2020 = 2020
    case jahr2021 = 2021

    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "jahr == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "keine Auswahl"
        case .jahr2016: return "2016"
        case .jahr2017: return "2017"
        case .jahr2018: return "2018"
        case .jahr2019: return "2019"
        case .jahr2020: return "2020"
        case .jahr2021: return "2021"
        }
    }
}


enum UnfallTyp1: Int, Identifiable, CaseIterable {
    case keineAuswahl = 0
    case fahrUnfall = 1
    case abbiegeUnfall = 2
    case einbiegenKreuzenUnfall = 3
    case ueberschreitenUnfall = 4
    case unfallDurchRuhendenVerkehr = 5
    case unfallImLaengsverkehr = 6
    case sonstigerUnfall = 7
 
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "unfallTyp1 == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .fahrUnfall: return "Fahrunfall (grün)"
        case .abbiegeUnfall: return "Abbiegeunfall (gelb)"
        case .einbiegenKreuzenUnfall: return "Einbiegen-/Kreuzenunfall (rot)"
        case .ueberschreitenUnfall: return "Überschreiten-Unfall (weiß)"
        case .unfallDurchRuhendenVerkehr: return "Unfall durch ruhenden Verkehr (blau)"
        case .unfallImLaengsverkehr: return "Unfall im Längsverkehr (orange)"
        case .sonstigerUnfall: return "Sonstiger Unfall (schwarz)"
        }
    }

    @ViewBuilder func sectionTextView(colorScheme: ColorScheme) -> some View {
        switch self {
        case .keineAuswahl:
            HStack() {
                Text("keine Auswahl")
                Image(systemName: "smallcircle.filled.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(red: 1, green: 0, blue: 0, opacity: 0), Color(red: 1, green: 0, blue: 0, opacity: 0)) // invisible symbol as placeholder
            }
        case .fahrUnfall:
            HStack() {
                Text("Fahrunfall")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .green)
            }
        case .abbiegeUnfall:
            HStack() {
                Text("Abbiegeunfall")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .yellow)
            }
        case .einbiegenKreuzenUnfall:
            HStack() {
                Text("Einbiegen-/Kreuzenunfall")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .red)
            }
        case .ueberschreitenUnfall:
            HStack() {
                Text("Überschreiten-Unfall")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .white)
            }
        case .unfallDurchRuhendenVerkehr:
            HStack() {
                Text("Unfall durch ruhenden Verkehr")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .blue).padding(.horizontal)
            }
        case .unfallImLaengsverkehr:
            HStack() {
                Text("Unfall im Längsverkehr")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .orange)
            }
        case .sonstigerUnfall:
            HStack() {
                Text("Sonstiger Unfall")
                Image(systemName: "smallcircle.filled.circle.fill").symbolRenderingMode(.palette).foregroundStyle(colorScheme == .dark ? .secondary : .quaternary, .black)
            }
        }
    }
}

enum UnfallKategorie: Int, Identifiable, CaseIterable {
    case keineAuswahl = 0
    case mitGetoeteten = 1
    case mitSchwerverletzten = 2
    case mitLeichtVerletzten = 3
 
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "unfallKategorie == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .mitGetoeteten: return "Mit Getöteten ✟"
        case .mitSchwerverletzten: return "Mit Schwerverletzten 🏥"
        case .mitLeichtVerletzten: return "Mit Leichtverletzten 🩹"
        }
    }
}

enum UnfallArt: Int, Identifiable, CaseIterable {
    case keineAuswahl = 10
    case mitAnfahrendemAnhaltendemRuhendemFzg = 1
    case mitVorausFahrendemWartendemFzg = 2
    case mitSeitlichFahrendemFzg = 3
    case mitEntgegenkommendemFzg = 4
    case mitEinbiegendemKreuzendemFzg = 5
    case zwischenFahrezeugUndFussgaenger = 6
    case aufprallAufFahrbahnhindernis = 7
    case abkommenNachRechts = 8
    case abkommenNachLinks = 9
    case unfallAndererArt = 0
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "unfallArt == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .mitAnfahrendemAnhaltendemRuhendemFzg: return "A1 Zusammenstoß mit anfahrendem/ anhaltendem/ruhendem Fahrzeug"
        case .mitVorausFahrendemWartendemFzg: return "A2 Zusammenstoß mit vorausfahrendem / wartendem Fahrzeug"
        case .mitSeitlichFahrendemFzg: return "A3 Zusammenstoß mit seitlich in gleicher Richtung fahrendem Fahrzeug"
        case .mitEntgegenkommendemFzg: return "A4 Zusammenstoß mit entgegenkommendem Fahrzeug"
        case .mitEinbiegendemKreuzendemFzg: return "A5 Zusammenstoß mit einbiegendem / kreuzendem Fahrzeug"
        case .zwischenFahrezeugUndFussgaenger: return "A6 Zusammenstoß zwischen Fahrzeug und Fußgänger"
        case .aufprallAufFahrbahnhindernis: return "A7 Aufprall auf Fahrbahnhindernis"
        case .abkommenNachRechts: return "A8 Abkommen von Fahrbahn nach rechts"
        case .abkommenNachLinks: return "A9 Abkommen von Fahrbahn nach links"
        case .unfallAndererArt: return " A0 Unfall anderer Art"
        }
    }
}

enum IstSonstige: Int, Identifiable, CaseIterable {
    case keineAuswahl = 2
    case ohneSonstige = 0
    case mitSonstige = 1
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "istSonstige == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .ohneSonstige: return "Ohne Sonstige-Kfz-Beteiligung"
        case .mitSonstige: return "Mit Sonstige-Kfz-Beteiligung 🚚/🚌/🚃"
        }
    }
}

enum IstGueterKfz: Int, Identifiable, CaseIterable {
    case keineAuswahl = 2
    case ohneGueterKfz = 0
    case mitGueterKfz = 1
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "istGueterKfz == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .ohneGueterKfz: return "Ohne Güter-Kfz-Beteiligung"
        case .mitGueterKfz: return "Mit Güter-Kfz-Beteiligung 🚚"
        }
    }
}


enum IstKrad: Int, Identifiable, CaseIterable {
    case keineAuswahl = 2
    case ohneKrad = 0
    case mitKrad = 1
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "istKrad == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .ohneKrad: return "Ohne Kraftradbeteiligung"
        case .mitKrad: return "Mit Kraftradbeteiligung 🏍️"
        }
    }
}

enum IstPkw: Int, Identifiable, CaseIterable {
    case keineAuswahl = 2
    case ohnePkw = 0
    case mitPkw = 1
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "istPkw == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .ohnePkw: return "Ohne Pkwbeteiligung"
        case .mitPkw: return "Mit Pkwbeteiligung 🚗"
        }
    }
}

enum IstFahrrad: Int, Identifiable, CaseIterable {
    case keineAuswahl = 2
    case ohneFahrrad = 0
    case mitFahrrad = 1
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "istFahrrad == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .ohneFahrrad: return "Ohne Fahrradbeteiligung"
        case .mitFahrrad: return "Mit Fahrradbeteiligung 🚴"
        }
    }
}

enum IstFussgaenger: Int, Identifiable, CaseIterable {
    case keineAuswahl = 2
    case ohneFussgaenger = 0
    case mitFussgaenger = 1
    
    var id: Self { self }
    var predicate: NSPredicate? {
        switch self {
        case .keineAuswahl:
            return nil
        default:
            return NSPredicate(format: "istFussgaenger == %i", self.rawValue)
        }
    }
    
    var sectionText: String {
        switch self {
        case .keineAuswahl: return "Keine Auswahl"
        case .ohneFussgaenger: return "Ohne Fußgängerbeteiligung"
        case .mitFussgaenger: return "Mit Fußgängerbeteiligung 🚶‍♂️"
        }
    }
}

//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView()
//    }
//}
