//
//  ContentViewUIKitMapView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 11.06.25.
//

//
//  ContentView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 13.01.23.
//

import SwiftUI
import CoreData
@preconcurrency import MapKit


struct UIKitMapCoordinatorReader: UIViewRepresentable {
    var onUpdate: (UIKitMapView.Coordinator) -> Void

    func makeUIView(context: Context) -> UIView {
        UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Wir suchen in der UIKit-Hierarchie nach dem MKMapView und dessen Delegate (= Coordinator)
        if let mapView = uiView.superview?.next as? MKMapView,
           let coordinator = mapView.delegate as? UIKitMapView.Coordinator {
            onUpdate(coordinator)
        }
    }
}

struct ContentViewUIKitMapView: View  {

    @ObservedObject var viewModel: ViewModel
//    @StateObject var viewModel = ViewModel()
    @StateObject var initializationViewModel = InitializationViewModel()
    @StateObject var locationManager = LocationManager()
    
    @State private var debounceTask: Task<Void, Never>? = nil
    @State private var showSymbols = false
    @State private var mapCameraPosition: MapCameraPosition = .region(LocationManager.regionForGermany)
    @State private var visibleRegion: MKCoordinateRegion = LocationManager.regionForGermany
    @State private var mapCamera: MapCamera? // needed to get heading angle
    @State private var mapStyleIsStandard = true
    @State private var show3D = false        // <-- NEW

    @Namespace var mapScope

    @State private var lookAroundScene: MKLookAroundScene?
    @State private var selectedAccident: AccidentStruct?
    @State private var selectedAccidentGRDB: AccidentStructGRDB?
    @State private var showLookAroundPreview = false
    @State private var isShowingFilterView = false
    @State private var isShowingInfoView = false
    @State private var isFetchingCountOfSelectedAccidents = false
    
    // For UIKit Mapt View
    @State private var mapCoordinator: UIKitMapView.Coordinator? = nil


    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .topTrailing) {
                                

                
//                UIKitMapView(
//                    initialRegion: LocationManager.regionForGermany, // <- oder wie auch immer du initialisieren willst
//                    accidents: viewModel.accidentStructsGRDB,
//                    mapStyleIsStandard: mapStyleIsStandard,
//                    show3D: false,
//                    onSelectAccident: { accident in
//                        selectedAccidentGRDB = accident
//                        getLookAroundScene(forAccident: accident)
//                    },
//                    onRegionChanged: { region in
//                        // Fetches bei echter Kartenbewegung!
//                        debounceTask?.cancel()
//                        debounceTask = Task {
//                            try? await Task.sleep(nanoseconds: 400_000_000)
//                            guard !Task.isCancelled else { return }
//                            viewModel.fetchAccidentsGRDB(region: region)
//                            viewModel.fetchCountInRegion(region: region)
//                        }
//                    },
//                    coordinatorRef: $mapCoordinator
//                )
  
                // --- Main map view with all required callbacks ---
                UIKitMapView(
                    initialRegion: LocationManager.regionForGermany,
                    accidents: viewModel.accidentStructsGRDB,
                    mapStyleIsStandard: mapStyleIsStandard,
                    show3D: show3D,
                    onSelectAccident: { accident in
                        selectedAccidentGRDB = accident
                        getLookAroundScene(forAccident: accident)
                    },
                    onRegionChanged: { region in
                        // Debounce user interaction (zoom/move) to avoid excessive database calls
                        debounceTask?.cancel()
                        debounceTask = Task {
                            try? await Task.sleep(nanoseconds: 400_000_000)
                            guard !Task.isCancelled else { return }
                            visibleRegion = region
                            viewModel.fetchAccidentsGRDB(region: region)
                            viewModel.fetchCountInRegion(region: region)
                        }
                    }
                )
                
                
//                .background(
//                    UIKitMapCoordinatorReader { coordinator in
//                        mapCoordinator = coordinator // Merke dir den Coordinator für spätere Region-Abfragen!
//                    }
//                )
                
                
//                .mapControls {
//                    MapScaleView()
//                }
                
                .mapStyle(mapStyleIsStandard ? .standard : .hybrid(elevation: .realistic))
                
                // LOOK AROUND PREVIEW AND BOTTOM TOOLBAR AND INITIALIZATION VIEW
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) {
                        
                        // Initialization information if needed.
                        if initializationViewModel.initializationState != .initalized {
                            InitializationView(viewModel: initializationViewModel)
                        }
                        
                        // Look around preview
                        if showLookAroundPreview {
                            LookAroundPreviewContainer(
                                scene: lookAroundScene,
                                selectedAccident: selectedAccidentGRDB,
                                isVisible: $showLookAroundPreview
                            )
                        }
                        
                        Divider()
                        
                        // Buttons at the bottom of the screen
//                        MapBottomToolbarView(
//                            mapScope: mapScope,
//                            locationAuthorized: locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways,
//                            mapStyleIsStandard: $mapStyleIsStandard,
//                            showSymbols: $showSymbols,
//                            showLookAroundPreview: $showLookAroundPreview
//                        )
                        MapBottomToolbarViewMapKit(
                            mapScope: mapScope,
                            locationAuthorized: locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways,
                            mapStyleIsStandard: $mapStyleIsStandard,
                            showSymbols: $showSymbols,
                            showLookAroundPreview: $showLookAroundPreview,
                            show3D: $show3D            // <-- Pass the binding!
                        )
                    }
//                    .mapControlVisibility(.visible)
                    .background(Color(.systemBackground))
                }
                
                
                // Overlay with text on number of accidents within region and number of accidents displayed and compass.
                AccidentMapOverlayView(
                    isFetchingAccidents: viewModel.isFetchingAccidents,
                    countOfAccidents: viewModel.accidentStructsGRDB.count,
                    isfetchingSelectedCountInRegion: viewModel.isFetchingSelectedCountInRegion,
                    selectedCountInRegion: viewModel.selectedCountInRegion,
                    mapCamera: mapCamera,
                    mapStyleIsStandard: mapStyleIsStandard,
                    mapScope: mapScope
                )
            }
//            .mapScope(mapScope)
            
            // NAVIGATION BAR (TOP TOOLBAR)
            .toolbar {
                // Text with count of selected accidents
                ToolbarItem(placement: .navigationBarLeading) {
                    CountOfSelectedAccidentsView(countOfAllAccidents: ViewModel.totalCountinGermany,
                                                 countOfSelectedAccidents: viewModel.selectedCountInGermany,
                                                 isFetchingCountOfSelectedAccidents: viewModel.isFetchingSelectedCountInGermany,
                                                 displayPercentage: initializationViewModel.isInitialized)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // (i) button
                    Button {
                        isShowingInfoView.toggle()
                        viewModel.clearAccidentsGRDB() // neded for speedup and responsiveness
                    } label: {
                        Label("Info", systemImage: "info.circle")
                    }
                    // filter button
                    Button {
                        isShowingFilterView.toggle()
                        viewModel.clearAccidentsGRDB()  // neded for speedup and responsiveness
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar) // to map not sneak unterneath
            
            // SHEET for INFOVIEW and FILTERVIEW
//            .sheet(isPresented: $isShowingInfoView, onDismiss: { dismissFilterViewAction() } ) {
//                InfoView(accidentsFetchLimit: viewModel.fetchLimit)
//            }
            .sheet(isPresented: $isShowingInfoView) {
                InfoView(accidentsFetchLimit: viewModel.fetchLimit)
            }
            .sheet(isPresented: $isShowingFilterView, onDismiss: { userDidChangeFilter() } ) {
                FilterView(viewModel: viewModel, accidentDataFilters: $viewModel.accidentDataFilters, isFetchingCountOfSelectedAccidents: $isFetchingCountOfSelectedAccidents, displayPercentage: initializationViewModel.isInitialized)
            }

            // User pressed button to show symbols or not
            .onChange(of: showSymbols) {
                print("============================== in .onChange(of: showSymbols) ===============================")
                viewModel.fetchAccidentsGRDB(region: visibleRegion)
                viewModel.fetchCountInRegion(region: visibleRegion)
            }


            // Update UI each time the initalization state changes (e.g. database deleted, a year is imported or finally fully initialized).
            // Will be called when view appears and each time the initialization state changes. Exactly what we want.
            .task(id: initializationViewModel.initializationState) {
                print("============================== in .task(of: initializationState) at \(Date.now.formatted(date: .complete, time: .complete)) ======================")
//                viewModel.getCountOfSelectedAccidents()
                viewModel.fetchCountInGermany()
                viewModel.fetchCountInRegion(region: visibleRegion)
            }
            
//            // User toggled the type of the map (between standard and hybrid map type)
//            .onChange(of: mapStyleIsStandard) {
//                print("============================== in .onChange(of: mapStyleIsStandard) ======================")
//                
//                // When the user changes the map type, the region is usualy changed, too. Might be due to different tile
//                // sizes. However, in this case the accidents must be fetched again for the new region.
//                // Here position is needed sind it fires the redrawing of the map and thus the recalculation of the
//                // visible region (after its change) and thereafter the respective accidents for this new region are
//                // fetched automatically in .onMapCameraChange.
//                mapCameraPosition = .region(visibleRegion)
//            }

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
                                
                viewModel.fetchAccidentsGRDB(region: visibleRegion)
                viewModel.fetchCountInRegion(region: visibleRegion)
            }
        }
    }
    
    // Action when dismissing InfoView or FilterView
    func dismissFilterViewAction() {
        print("============================== in func dismissAction ======================")
        viewModel.fetchAccidentsGRDB(region: visibleRegion)
        viewModel.fetchCountInRegion(region: visibleRegion)
    }
    func userDidChangeFilter() {
//        if let region = mapCoordinator?.lastRegion {
//            viewModel.fetchAccidentsGRDB(region: region)
//            viewModel.fetchCountInRegion(region: region)
//        }
        viewModel.fetchAccidentsGRDB(region: visibleRegion)
        viewModel.fetchCountInRegion(region: visibleRegion)
    }
    
    func getLookAroundScene (forAccident accident: AccidentStructGRDB?) {
        lookAroundScene = nil
        Task {
            if let accident {
                let request = MKLookAroundSceneRequest(coordinate: accident.coordinate)
                lookAroundScene = try? await request.scene
            }
//            print("getLookAroundScene finished")
        }
    }
        
}

//struct ContentView_Previews: PreviewProvider {
//    static var viewModel = ViewModel()
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}


