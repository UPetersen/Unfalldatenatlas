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
            
            ForEach(accidents) { accident in
                // MARK: BEWARE: Annotation text could also be used for symbols information text
                Annotation("", coordinate: accident.coordinate, anchor: .center) {
                    AccidentAnnotationView(
                        accident: accident,
                        showSymbol: showSymbols,
                        isSelected: accident == selectedAccident,
                        onTap: {
                            if accident == selectedAccident {
                                onSelectAccident(nil)
                            } else {
                                onSelectAccident(accident)
                            }
                        }
                    )
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
