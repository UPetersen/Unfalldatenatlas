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

    @StateObject var initializationViewModel = InitializationViewModel()
    @ObservedObject var viewModel: ViewModel
    
    @State private var moveToCurrentLocation = false
    @State private var showSymbols = false
    @State private var mapType: MKMapType = .standard
    init(viewModel: ViewModel) {
        viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: viewModel.locationManager.latitudeOrMiddleOfGermany,
                                                                             longitude: viewModel.locationManager.longitudeOrMiddleOfGermany),
                                              latitudinalMeters: 5000,
                                              longitudinalMeters: 5000
        )
        self.viewModel = viewModel
    }
    
//    @State private var theRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.6494018, longitude: 9.1091648), latitudinalMeters: 10000, longitudinalMeters: 10000)
        
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .topLeading) {
                
                // Use MKMapView package from https://github.com/pauljohanneskraft/Map
                Map(
//                    coordinateRegion: $theRegion,
                    coordinateRegion: $viewModel.region,
                    type: mapType,   //.standard,
                    informationVisibility: MapInformationVisibility(arrayLiteral: .buildings, .compass, .scale, .userLocation),
                    annotationItems: viewModel.accidents,
                    annotationContent: { accident in
                        ViewMapAnnotation(coordinate: accident.coordinate) {
                            ZStack() {
                                Circle().stroke(colorForAccidentType1(accident: accident), lineWidth: 5)
                                    .frame(width: 15, height: 15)
                                // Show symbols for accidents, if user taps once. Handled via opacity
                                Text("\(accident.jahr - 2000)\(symbolsForAccident(accident: accident))")
                                    .font(.title2)
                                    .padding(.horizontal, 5)
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                    .padding(.top, 40)
                                    .opacity(showSymbols ? 1 : 0)   // Otherwhise the view is only fully visible after panning or pitching
                                    .frame(width: 400)
                            }
                         }
                    }
                )
                
                // User pressed button to show symbols or not
                .onChange(of: showSymbols, debounceTime: 0.1) { showSymbols in
                    Task {
                        viewModel.refetchAccidents()
                    }
                }
                // User pressed button to move to current location
                .onChange(of: moveToCurrentLocation) { _ in
                    moveToCurrentLocation.toggle()
                    viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: viewModel.locationManager.latitudeOrMiddleOfGermany,
                                                                                         longitude: viewModel.locationManager.longitudeOrMiddleOfGermany),
                                                          latitudinalMeters: 5000,
                                                          longitudinalMeters: 5000)
                }
                // User moved map or zoomed in or out
                .onReceive(viewModel.$region.debounce(for: 0.1, scheduler: RunLoop.main)) { region in
//                    viewModel.fetchTheAccidents(region: region) // viewModel.fetchTheAccidents(region: viewModel.region)
                    viewModel.fetchTheAccidents() // viewModel.fetchTheAccidents(region: viewModel.region)
                }
                // Button for changing between standard and satellite map
                VStack {
                    HStack {
                        Spacer()
                    }
                    .padding([.top, .bottom], 30)
                    HStack() {
                        Spacer()
                        MapConfigurationView(mapType: $mapType,
                                             showSymbols: $showSymbols,
                                             moveToCurrentLocation: $moveToCurrentLocation,
                                             showLocationButton: viewModel.locationManager.isAuthorized
                        )
                    }

                    // Initialization information if needed.
                    if initializationViewModel.initializationState != .initalized {
                        InitializationView(viewModel: initializationViewModel)
                    }
                }
            }
            .onAppear() {
                // Request to use current position only if the user had not yet been asked.
                if viewModel.locationManager.locationStatus == .notDetermined {
                    viewModel.locationManager.requestAuthorization()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("\(viewModel.accidents.count) von \(viewModel.countOfAllAccidents) Unf??llen")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        InfoView()
                        
                    } label: {
                        Label("Info", systemImage: "info.circle")
                        
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
//                        FilterView(viewModel: viewModel, accidentDataFilters: self.$viewModel.accidentDataFilters, theRegion: theRegion)
//                        FilterView(viewModel: viewModel, accidentDataFilters: self.$viewModel.accidentDataFilters, theRegion: viewModel.region)
                        FilterView(viewModel: viewModel, accidentDataFilters: self.$viewModel.accidentDataFilters)
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
        if accident.istPkw { symbol.append("????") }
        if accident.istKrad { symbol.append("???????") }
        if accident.istFahrrad { symbol.append("????") }
        if accident.istFussgaenger { symbol.append("?????????????") }
        // G??terkraffahrzeuge: Unfall mit G??terkraftfahrzeug (GKFZ): Unfall, an dem mindestens ein Lastkraftwagen mit
        // Normalaufbau und einem Gesamtgewicht ??ber 3,5 t, ein Lastkraftwagen mit Tankauflage bzw. Spezialaufbau,
        // eine Sattelzugmaschine oder eine andere Zugmaschine beteiligt war (diese Kategorie ist in
        // den Jahren 2016 und 2017 in "Unfall mit Sonstigen" enthalten)
        if accident.istGueterKfz { symbol.append("????") }
        // Unfall mit Sonstigen: Unfall, an dem mindestens ein oben nicht genanntes Verkehrsmittel beteiligt war, wie
        // z. B. ein Bus oder eine Stra??enbahn (2016 und 2017 einschlie??lich Unfall mit G??terkraftfahrzeug (GKFZ),
        // ab 2018 ohne Unfall mit GKFZ)
        if accident.istSonstige {
            if accident.jahr >= 2018 {
                symbol.append("????/????")
            } else {
                symbol.append("????/????/????")
            }
        }
        
        // Light Conditions, not icon for twilight (D??mmerung) available, so just made it night, too.
        if accident.lichtVerhaeltnisse >= 1 {symbol.append("????") }
        
        // Road conditions
        if accident.strassenZustand == 1 {
            symbol.append("???????")
        } else if accident.strassenZustand == 2 {
            symbol.append("??????")
        }
        
        //Accident Category (Unfallkategorie): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        switch accident.unfallKategorie {
        case 1: symbol.append("???")
        case 2: symbol.append("????")
        case 3: symbol.append("????")
        default: fatalError("Wrong Unfallkategorie: \(accident.unfallKategorie). Must be 1, 2 or 3.")
        }
     
        // Accident kind (Unfallart): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Zusammensto?? mit anfahrendem/ anhaltendem/ruhendem Fahrzeug
        // 2 = Zusammensto?? mit vorausfahrendem / wartendem Fahrzeug
        // 3 = Zusammensto?? mit seitlich in gleicher Richtung fahrendem Fahrzeug
        // 4 = Zusammensto?? mit entgegenkommendem Fahrzeug
        // 5 = Zusammensto?? mit einbiegendem / kreuzendem Fahrzeug
        // 6 = Zusammensto?? zwischen Fahrzeug und Fu??g??nger
        // 7 = Aufprall auf Fahrbahnhindernis
        // 8 = Abkommen von Fahrbahn nach rechts
        // 9 = Abkommen von Fahrbahn nach links Unfall
        // 0 = anderer Art
        symbol.append("A\(accident.unfallArt)")
        
        // Accident type (Unfalltyp1): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Fahrunfall (gr??n)
        // 2 = Abbiegeunfall (gelb)
        // 3 = Einbiegen / Kreuzen-Unfall (rot)
        // 4 = ??berschreiten-Unfall (wei??)
        // 5 = Unfall durch ruhenden Verkehr (blau)
        // 6 = Unfall im L??ngsverkehr (orange)
        // 7 = sonstiger Unfall (schwarz)
//        symbol.append("T\(accident.unfallTyp1)")
        
        return symbol
    }
    
    /// Returns the color to use for Unfall Type 1, as of https://de.wikipedia.org/wiki/Unfalltyp
    func colorForAccidentType1(accident: Accident) -> Color {
        switch accident.unfallTyp1 {
        case 1: return Color.green   // 1 = Fahrunfall
        case 2: return Color.yellow  // 2 = Abbiegeunfall
        case 3: return Color.red     // 3 = Einbiegen / Kreuzen-Unfall
        case 4: return Color.white   // 4 = ??berschreiten-Unfall
        case 5: return Color.blue    // 5 = Unfall durch ruhenden Verkehr
        case 6: return Color.orange  // 6 = Unfall im L??ngsverkehr
        case 7: return Color.black   // 7 = sonstiger Unfall
        default:
            fatalError("Wrong Unfalltyp 1: \(accident.unfallTyp1). Must be one out of 1 to 7.")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var viewModel = ViewModel()
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}


