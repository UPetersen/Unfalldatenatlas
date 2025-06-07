//
//  AccidentMapContentView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 03.06.25.
//

import SwiftUI
import MapKit


/// A reusable map view that displays accident annotations with optional symbol overlays.
/// Selection and tap handling is supported. Camera changes are handled externally.
struct AccidentMapContentView: View {
    @Binding var mapCameraPosition: MapCameraPosition
    let mapScope: Namespace.ID
    let showSymbols: Bool
    let accidents: [AccidentStructGRDB]
    let selectedAccident: AccidentStructGRDB?
    let onSelectAccident: (AccidentStructGRDB?) -> Void
    
    var body: some View {

        Map(position: $mapCameraPosition, scope: mapScope) {
            
            UserAnnotation()  // Show user location (blue dot)
            
            // Case A: showSymbols == true → draw symbol for all accidents
            if showSymbols {
                // Circles with text symbols (the emojis) for each accident
                ForEach(accidents) { accident in
                    // MARK: BEWARE: Annotation text could also be used for symbols information text
                    Annotation("", coordinate: accident.coordinate, anchor: .center) {
                        Button {
                            print("==================== Button pressed ===================")
                            if accident == selectedAccident {
                                onSelectAccident(nil)
                            } else {
                                onSelectAccident(accident)
                            }
                        } label: {
                            Circle()
                                .stroke(accident.color, lineWidth: accident == selectedAccident ? 12 : 5)
                                .padding()
                                .overlay() {
                                    SymbolsTextViewGRDB(accident: accident).allowsHitTesting(false) // The emojis
                                }
                        }
                        //                            .disabled(!showLookAroundPreview) // Button disable (to still have double tap zoom when no preview)
                    }
                }
            } else {
                // Case B: showSymbols == false → show symbol only for selected accident
                ForEach(accidents, id: \.id) { accident in
                    Annotation("", coordinate: accident.coordinate, anchor: .center) {
                        Button {
                            print("==================== Button pressed ===================")
                            if accident == selectedAccident {
                                onSelectAccident(nil)
                            } else {
                                onSelectAccident(accident)
                            }
                        } label: {
                            Circle()
                                .stroke(accident.color, lineWidth: accident == selectedAccident ? 12 : 5)
                                .padding()
                        }
                        .overlay() {
                            SymbolsTextViewGRDB(accident: accident).allowsHitTesting(false) // The emojis
                                .opacity(accident == selectedAccident ? 1 : 0)
                        }
                    }
                }
            }
        }
        // Clicking anywhere in the map (which is not the circle of an accident) deselects the previously selected accident.
        .simultaneousGesture(
            TapGesture(count: 1).onEnded {
                onSelectAccident(nil)
            }
        )
    }
}


///// A reusable map view that displays accident annotations with optional symbol overlays.
///// Handles tap gestures and selection via callback.
///// Does *not* manage camera changes – this is left to the parent view.
//struct AccidentMapContentView: View {
//    @Binding var mapCameraPosition: MapCameraPosition
//    let mapScope: Namespace.ID
//    let showSymbols: Bool
//    let accidents: [AccidentStructGRDB]
//    let selectedAccident: AccidentStructGRDB?
//    let onSelectAccident: (AccidentStructGRDB?) -> Void
//
//    var body: some View {
//        Map(position: $mapCameraPosition, scope: mapScope) {
//            
//            // Show user location (blue dot)
//            UserAnnotation()
//            
//            // Draw annotations for all accidents
//            ForEach(accidents) { accident in
//                Annotation("", coordinate: accident.coordinate, anchor: .center) {
//                    ZStack {
//                        // Tap target: colored circle (changes stroke if selected)
//                        Button(action: {
//                            if accident == selectedAccident {
//                                onSelectAccident(nil)
//                            } else {
//                                onSelectAccident(accident)
//                            }
//                        }) {
//                            Circle()
//                                .stroke(
//                                    accident.color,
//                                    lineWidth: accident == selectedAccident ? 12 : 5
//                                )
//                                .frame(width: 10, height: 10) // 👈 visuelle Größe
//                                .contentShape(Circle()) // 👈 macht genau diesen Kreis tappbar (optional)
//                                .background(
//                                    Circle()
//                                        .fill(Color.clear)
////                                        .frame(width: 44, height: 44) // 👈 tappbare Fläche
//                                        .frame(width: 60, height: 60) // 👈 tappbare Fläche
//                                )
////                                .padding()
//                        }
//
//                        // Emoji layer (always rendered, but can be transparent)
//                        SymbolsTextViewGRDB(accident: accident)
//                            .allowsHitTesting(false) // Don't block taps
//                            .opacity(symbolOpacity(for: accident))
//                    }
//                }
//            }
//        }
//        // Tap on map deselects accidents
//        .simultaneousGesture(
//            TapGesture(count: 1).onEnded {
//                onSelectAccident(nil)
//            }
//        )
//    }
//
//    /// Determines visibility of symbol overlay depending on app state
//    private func symbolOpacity(for accident: AccidentStructGRDB) -> Double {
//        if showSymbols {
//            return 1.0
//        } else {
//            return accident == selectedAccident ? 1.0 : 0.0
//        }
//    }
//}

//
///// A reusable map view that displays accident annotations with optional symbol overlays.
///// It does not react to region changes or camera changes — those are handled externally.
//struct AccidentMapContentView: View {
//    @Binding var mapCameraPosition: MapCameraPosition
//    let mapScope: Namespace.ID
//    let showSymbols: Bool
//    let accidents: [AccidentStructGRDB]
//    let selectedAccident: AccidentStructGRDB?
//    let onSelectAccident: (AccidentStructGRDB?) -> Void
//
//    var body: some View {
//        Map(position: $mapCameraPosition, scope: mapScope) {
//            
//            // Show user's location on map (blue dot)
//            UserAnnotation()
//
//            // Draw a circle and optional emoji for each accident
//            ForEach(accidents) { accident in
//                Annotation("", coordinate: accident.coordinate, anchor: .center) {
//                    Button(action: {
//                        if accident == selectedAccident {
//                            onSelectAccident(nil)
//                        } else {
//                            onSelectAccident(accident)
//                        }
//                    }) {
//                        Circle()
//                            .stroke(accident.color, lineWidth: accident == selectedAccident ? 12 : 5)
//                            .padding()
//                            .overlay {
//                                if showSymbols {
//                                    SymbolsTextViewGRDB(accident: accident)
//                                        .allowsHitTesting(false)
//                                }
//                            }
//                    }
//                    .disabled(!showSymbols)
//                    .overlay {
//                        if !showSymbols {
//                            SymbolsTextViewGRDB(accident: accident)
//                                .allowsHitTesting(false)
//                                .opacity(accident == selectedAccident ? 1 : 0)
//                        }
//                    }
//                }
//            }
//        }
//        .simultaneousGesture(
//            TapGesture(count: 1).onEnded {
//                // Deselect accident when tapping on empty space
//                onSelectAccident(nil)
//            }
//        )
//    }
//}
