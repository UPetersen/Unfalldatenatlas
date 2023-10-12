//
//  ContentView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 13.01.23.
//

import SwiftUI
import CoreData
import MapKit

struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var viewModel: ViewModel
    @StateObject var initializationViewModel = InitializationViewModel()
    @StateObject var locationManager = LocationManager()

    @State private var task: Task<Void, Never>? = nil

    @State private var showSymbols = false
    @State private var mapCameraPosition: MapCameraPosition = .region(LocationManager.regionForGermany)
    @State private var visibleRegion: MKCoordinateRegion = LocationManager.regionForGermany
    @State private var mapCamera: MapCamera? // needed to get heading angle
    @State private var mapStyleIsStandard = true

    @Namespace var mapScope

    @State private var lookAroundScene: MKLookAroundScene?
    @State private var selectedCoordinate: CLLocationCoordinate2D? // = LocationManager.regionForGermany.center
    @State private var showLookAroundPreview = false
    
    @State private var isShowingFilterView = false
    @State private var isShowingInfoView = false
    
    @State private var isFetchingCountOfSelectedAccidents = false

    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .topTrailing) {
                
                // Use initializer with $position, otherwhise position waggles several times, when coming back from filter view
                // I do not understand why. $position should actually not be needed.
                Map(position: $mapCameraPosition, scope: mapScope) {

                    UserAnnotation() // Displays the blue circle for user's position
                    
                    // Example for using marker instead of Annotation, keep if once needed.
                    // Works, but bottowm of the shape is the accident point (not the middle)
                    // Keep, untill markers are displayed in Germany Look Around view (which is
                    // unfortunately not the case as of 2023-10-03)
//                    if !viewModel.accidents.isEmpty {
//                        ForEach(viewModel.accidents) { accident in
//                            Marker("UNFALL",
//                                   systemImage: "circle", coordinate: accident.coordinate)
//                            .annotationTitles(.visible)
//                            .tint(colorForAccidentType1(accident: accident))
//                        }
//                    }
                    
                    // Draw Circle on map for each Accident and conditionally show symbols text
                    // Big sppeed up to separate
                    if !viewModel.accidents.isEmpty {
                        // Some sppeed up to distinguish the two cases of displaying symbols or not in the following way
                        if showSymbols {
                            ForEach(viewModel.accidents) { accident in
                                // MARK: BEWARE: Annotaton text could also be useed for symbols information text
                                Annotation("", coordinate: accident.coordinate, anchor: .center) {
                                    Button(action: {
                                        print("==================== Button pressed ===================")
                                        selectedCoordinate = accident.coordinate
                                        getLookAroundScene()
                                    }) {
                                        Circle().stroke(colorForAccidentType1(accident: accident), lineWidth: 5)
                                            .padding()
                                            .overlay() {
                                                SymbolsTextView(accident: accident).allowsHitTesting(false)
                                            }
                                    }
                                    .disabled(!showLookAroundPreview) // Button disable (to still have double tap zoom when no preview)
                                }
                            }
                        } else {
                            ForEach(viewModel.accidents) { accident in
                                Annotation("", coordinate: accident.coordinate, anchor: .center) {
                                    Button(action: {
                                        print("==================== Button pressed ===================")
                                        selectedCoordinate = accident.coordinate
                                        getLookAroundScene()
                                    }) {
                                        Circle().stroke(colorForAccidentType1(accident: accident), lineWidth: 5)
                                            .padding()
                                    }
                                    .disabled(!showLookAroundPreview) // Button disable (to still have double tap zoom when no preview)
                                }
                            }
                        }
                    }
                }
                .mapControls {
                    MapScaleView()
                }
                .mapStyle(mapStyleIsStandard ? .standard : .hybrid(elevation: .realistic))
                
                // LOOK AROUND PREVIEW AND BOTTOM TOOLBAR
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) {
                        
                        // Look around preview
                        if showLookAroundPreview { // selectedCoordinate != nil {
                            LookAroundPreview(initialScene: lookAroundScene)
                                .frame (height: 128)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .overlay() {
                                    Text("Keine Lookaround-Ansicht vorhanden, kein Unfall ausgewählt oder Internetverbindung eingeschränkt.")
                                        .padding(.horizontal) // left and right distance to edges of dark colored box
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity) // extend dark colored box horizontally to edge of LookAroundPreview
                                        .frame(maxHeight: .infinity) // extend dark colored box verticall to edge or LookAroundPreview
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(.horizontal, 10) // apply same padding as LookAroundPreview
                                        .padding(.vertical, 5)    // apply same padding as LookAroundPreview
                                        .opacity((lookAroundScene == nil) ? 1 : 0)
                                }
                        }
                        
                        Divider()
                        
                        // Buttons at the bottom of the screen
                        HStack {
                            // Caveat: the first two buttons do not scale with the system font, but the latter three do.
                            // I did not find a ways to scale the first two buttons.
                            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                                MapUserLocationButton(scope: mapScope)
                            }
                            MapPitchToggle(scope: mapScope)
                            
                            // Button to toggle between standard and hybrid view
                            Button(action: { mapStyleIsStandard.toggle() }) {
                                Image(systemName: mapStyleIsStandard ? "map" : "map.fill")
                                    .font(.system(size: 18)) // keep size independent to system font size, because of above mentioned bug
                            }
                            .padding(.horizontal)
                            
                            // Button to toggle between showing symbols for the accidents or not
                            Button(action: { showSymbols.toggle() }) {
                                Image(systemName: showSymbols ? "ellipsis.rectangle.fill" : "ellipsis.rectangle")
                                    .font(.system(size: 18)) // keep size independent to system font size, because of above mentioned bug
                                    .padding([.top, .bottom], 8)
                            }
                            .padding(.horizontal)
                            
                            // Button to toggle between showing look around preview or not
                            Button(action: { showLookAroundPreview.toggle() }) {
                                Image(systemName: showLookAroundPreview ? "binoculars.fill" : "binoculars")
                                    .font(.system(size: 18)) // keep size independent to system font size, because of above mentioned bug
                                    .padding([.top, .bottom], 8)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    }
                    .mapControlVisibility(.visible)
                    .background(Color(.systemBackground))
                }
                
                // Update map when user pinched, zoomed or panned and set a new region
                // Must run ".continuos" for the delay/debounce to become effective. (Otherwise it
                // fires after each finish of moving the fingers plus the delay time, even if the user
                // continued moving his finger on the map again within the delay time.
                .onMapCameraChange(frequency: .continuous) { context in
                    print("==============================  in .onMapCameraChange(...) ============================")
                    // BEWARE: contex has always a camera, a rect and a region as properties.
                    // We need camera (for its heading property) and region

                    viewModel.isFetchingAccidents = true
                    // General decision: raises responsiveness dramatically, but instantly no accidents shown any more while moving the map
                    if viewModel.accidents.count > 100 {
                        viewModel.accidents = []
                    }
                    
                    self.mapCamera = context.camera
                    self.visibleRegion = context.region
                    
                    // Works, could overall be more responsive
                    task?.cancel()
                    task = Task {
                        try? await Task.sleep(nanoseconds: 300_000_000) // Delay (debounce) for some time
                        if Task.isCancelled {
//                            print("Task cancelled")
                        } else {
                            print("Task, not cancelled, starting")
                            // async seems to result in more responsive UI
                            await viewModel.fetchAccidentsAsync(region: context.region)
                            print("In Task, not cancelled, ended")
                        }
                    }
                }
                
                // Text on number of accidents within region and number of accidents displayed.
                VStack(alignment: .center) {
                    HStack(alignment: .bottom) {
                        Spacer()
                        if viewModel.isFetchingAccidents {
                            Group {
                                ProgressView()
                                Text(" Lade Daten für Kartenausschnitt ... ")
                            }
                        } else {
                            Text(infoTextForRegion)
                            .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color(.tertiarySystemBackground)).opacity(0.75)
                    .padding([.bottom], 30)

                    // Initialization information if needed.
                    if initializationViewModel.initializationState != .initalized {
                        InitializationView(viewModel: initializationViewModel)
                    }

                    
                    // Seems to be a bug in mac catalyst, but compass is not displayed on map using the .mapControls modifier, thus manually here
                    HStack{
                        Spacer()
                        MapCompass(scope: mapScope)
                            .padding(.horizontal)
                    }
                    
//#if DEBUG
//                    Text( (position.region != nil) ? "Fläche ist \(Int(position.region!.areaInSquareKilometers)) km^2" : "Fehler: position.region ist nil.")
//#endif
                    
                }
            }
            .mapScope(mapScope)
            
            // NAVIGATION BAR (TOP TOOLBAR)
            .toolbar {
                // Text with count of selected accidents
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading) {
                        CountOfSelectedAccidentsView(countOfSelectedAccidents: viewModel.countOfSelectedAccidents, isFetchingCountOfSelectedAccidents: isFetchingCountOfSelectedAccidents)
                    }
                }
                // The (i) button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingInfoView.toggle()
                        viewModel.accidents = [] // neded for speedup and responsiveness
                    }) {
                        Label("Info", systemImage: "info.circle")
                    }
                }
                // The filter button
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Use sheet, because there is some significant lag if using NavigationLink.
                    Button(action: {
                        isShowingFilterView.toggle()
                        viewModel.accidents = [] // neded for speedup and responsiveness
                    }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar) // to map not sneak unterneath
            
            // SHEET for INFOVIEW and FILTERVIEW
            .sheet(isPresented: $isShowingInfoView, onDismiss: { dismissAction() /* no dismiss action needed */} ) {
                InfoView(accidentsFetchLimit: viewModel.fetchLimit)
            }
            .sheet(isPresented: $isShowingFilterView, onDismiss: { dismissAction() /* no dismiss action needed */} ) {
                FilterView(viewModel: viewModel, accidentDataFilters: $viewModel.accidentDataFilters, isFetchingCountOfSelectedAccidents: $isFetchingCountOfSelectedAccidents)
            }

            // User pressed button to show symbols or not
            .onChange(of: showSymbols) {
                print("============================== in .onChange(of: showSymbols) ===============================")
                cancelTaskAndFetchAccidentsAsync()
            }
            
            // Update UI each time the initalization state changes (e.g. database deleted, a year is imported or finally fully initialized).
            .onChange(of: initializationViewModel.initializationState) {
                print("============================== in .onChange(of: initializationState) ======================")

                isFetchingCountOfSelectedAccidents = true
                task?.cancel()
                task = Task {
                    await viewModel.fetchCountOfSelectedAccidents() // Triggers also fetching of accidents.
                    if Task.isCancelled {
                        print("------Task fetchCountOfSelectedAccidents is cancelled in ContentView ----------")
                        return
                    }
                    isFetchingCountOfSelectedAccidents = false
                }
            }
            
            // User comes back from filter view (count of selected accidents can only be changed in the filter view
            // Not used any more due to speed/responsiveness updates. This property is only changed in FilterView, thus,
            // when FilterView is dismissed, the accidents have to be fetched again, but this is handled elsewhere.
//            .onChange(of: viewModel.countOfSelectedAccidents) {
//                print("============================== in .onChange(of: countOfSelectedAccidents) ======================")
//
//                task?.cancel()
//                task = Task {
//                    // async seems to result in more responsive UI
//                    await viewModel.fetchAccidentsAsync(region: visibleRegion)
//
//                }
//            }

            // User toggled the type of the map (between standard and hybrid map type)
            .onChange(of: mapStyleIsStandard) {
                print("============================== in .onChange(of: mapStyleIsStandard) ======================")
                
                // When the user changes the map type, the region is mostly changed, too. Might be due to different tile
                // sizes. However, in this case the accidents must be fetched again for the new region.
                // Here position is needed sind it fires the redrawing of the map and thus the recaculation of the
                // visible region (after its change) and thereafter the respective accidents for this new region are
                // fetched automatically in .onMapCameraChange.
                mapCameraPosition = .region(visibleRegion)
            }

            // .task instead of .onAppear, .task runs once, when view appears, and it runs asynchronously.
            // This is not called when returning from InfoView or FilterView (as long as they remain sheets).
            .task() {
                print("==============================  in .task() ===================================")

                // Request to use current position only if the user had not yet been asked, must run async
                if locationManager.authorizationStatus == .notDetermined {
                    DispatchQueue.main.async {
                        locationManager.requestAuthorization()
                    }
                }
//                cancelTaskAndFetchAccidentsAsync()
                await viewModel.fetchAccidentsAsync(region: visibleRegion)

            }

        }
    }
    
    // Action when dismissing InfoView or FilterView
    func dismissAction() {
        print("============================== in func dismissAction ======================")
        cancelTaskAndFetchAccidentsAsync()
    }
    
    func cancelTaskAndFetchAccidentsAsync() {
        print("============================== in func cancelTaskAndFetchAccidentsAsync ======================")
        task?.cancel()
        task = Task {
            await viewModel.fetchAccidentsAsync(region: visibleRegion)
        }
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
    
    func getLookAroundScene () {
        lookAroundScene = nil
        Task {
            if let selectedCoordinate {
                let request = MKLookAroundSceneRequest(coordinate: selectedCoordinate)
//                lookAroundScene = try? await request.scene
                do {
                    lookAroundScene = try await request.scene
                } catch  {
                    lookAroundScene = nil
                }
            }
            print("getLookAroundScene finished")
        }
    }
    
    var infoTextForRegion: String {
        var text: String = "Error or no value."
        
        if let mapCamera, !mapStyleIsStandard  || (0.5 < mapCamera.heading && mapCamera.heading < 355.5) || 0.5 < mapCamera.pitch {
            // Camera is not standard map, not in north or pitch is no zero (not in 2D) -> no count information in visible region since not accurate
            text = "Unfallzahl für Kartenausschnitt nur bei Standardkarte in Nordausrichtung"
        } else {
            if viewModel.accidents.count >= viewModel.fetchLimit {
                text = "\(viewModel.fetchLimit) oder mehr Unfälle im Kartenausschnitt (\(viewModel.fetchLimit) angezeigt)"
            } else {
                text = "\(viewModel.accidents.count) Unfälle im Kartenausschnitt"
            }
//            #if DEBUG
//            text = "\(viewModel.countOfAccidentsInRegion) Unfälle im Kartenausschnitt (\(viewModel.accidents.count) angezeigt)"
//            #endif
        }
//        print("Mapcamera: style standard: \(mapStyleIsStandard), heading is \(String(describing: mapCamera?.heading)), pitch is \(String(describing: mapCamera?.pitch)) ")
        return text
    }
    

}

//struct ContentView_Previews: PreviewProvider {
//    static var viewModel = ViewModel()
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}


