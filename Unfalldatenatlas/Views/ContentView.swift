//
//  ContentView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 13.01.23.
//

import SwiftUI
import CoreData
@preconcurrency import MapKit

struct ContentView: View  {

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

    @Namespace var mapScope

    @State private var lookAroundScene: MKLookAroundScene?
    @State private var selectedAccident: AccidentStruct?
    @State private var selectedAccidentGRDB: AccidentStructGRDB?

    @State private var showLookAroundPreview = false
    
    @State private var isShowingFilterView = false
    @State private var isShowingInfoView = false
    
    @State private var isFetchingCountOfSelectedAccidents = false

    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .topTrailing) {
                                
                // Use initializer with $position, otherwhise position waggles several times, when coming back from filter view
                // I do not understand why. $position should actually not be needed.
                AccidentMapContentView(
                    mapCameraPosition: $mapCameraPosition,
                    mapScope: mapScope,
                    showSymbols: showSymbols,
                    accidents: viewModel.accidentStructsGRDB,
                    selectedAccident: selectedAccidentGRDB,
                    onSelectAccident: { newSelection in
                        selectedAccidentGRDB = newSelection
                        getLookAroundScene(forAccident: newSelection)
                    }
                )
                
                .mapControls {
                    MapScaleView()
                }
                
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
                        MapBottomToolbarView(
                            mapScope: mapScope,
                            locationAuthorized: locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways,
                            mapStyleIsStandard: $mapStyleIsStandard,
                            showSymbols: $showSymbols,
                            showLookAroundPreview: $showLookAroundPreview
                        )
                    }
                    .mapControlVisibility(.visible)
                    .background(Color(.systemBackground))
                }
                
                // Update map when user pinched, zoomed or panned and thus set a new region
                // Must run ".continuos" f ror the delay/debounce to become effective. (Otherwise it
                // fires after each finish of moving the fingers plus the delay time, even if the user
                // continued moving his finger on the map again within the delay time.
                .onMapCameraChange(frequency: .continuous) { context in
                    print("============================== in .onMapCameraChange  ===============================")


                    guard self.visibleRegion != context.region else { return }
                    print("🔁 Durch erste Stufe durchgerutscht: Region changed significantly → loading new accidents")
//                    guard !visibleRegion.isApproximatelyEqual(to: context.region, tolerancePercent: 1) else { return }
//                    print("🔁 Durch zweite Stufe auch durchgerutscht: Region changed significantly → loading new accidents")
                    self.visibleRegion = context.region
                    self.mapCamera = context.camera

                    // General decision: raises responsiveness dramatically, but instantly no accidents shown any more while moving the map
                    if viewModel.accidentStructsGRDB.count > 100 && !viewModel.accidentStructsGRDB.isEmpty {
                        viewModel.clearAccidentsGRDB()
                    }

                    debounceTask?.cancel()
                    debounceTask = Task {
                                                
                        try? await Task.sleep(nanoseconds: 400_000_000) // Delay (debounce) for some time
                        
                        guard !Task.isCancelled else { return }
                        viewModel.fetchAccidentsGRDB(region: context.region)
                        viewModel.fetchCountInRegion(region: context.region)
                    }
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
            .mapScope(mapScope)
            
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
            .sheet(isPresented: $isShowingInfoView, onDismiss: { dismissFilterViewAction() } ) {
                InfoView(accidentsFetchLimit: viewModel.fetchLimit)
            }
            .sheet(isPresented: $isShowingFilterView, onDismiss: { dismissFilterViewAction() } ) {
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
            
            // User toggled the type of the map (between standard and hybrid map type)
            .onChange(of: mapStyleIsStandard) {
                print("============================== in .onChange(of: mapStyleIsStandard) ======================")
                
                // When the user changes the map type, the region is usualy changed, too. Might be due to different tile
                // sizes. However, in this case the accidents must be fetched again for the new region.
                // Here position is needed sind it fires the redrawing of the map and thus the recalculation of the
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
//                viewModel.fetchAccidentsGRDB(region: visibleRegion)
//                viewModel.fetchCountInRegion(region: visibleRegion)
            }
        }
    }
    
    // Action when dismissing InfoView or FilterView
    func dismissFilterViewAction() {
        print("============================== in func dismissAction ======================")
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


