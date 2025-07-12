//
//  MapBottomToolbarViewMapKit.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 29.06.25.
//

import SwiftUI
import MapKit

/// Toolbar for map controls: user location, pitch (3D), map style, symbols, look-around.
struct MapBottomToolbarViewMapKit: View {
    let mapScope: Namespace.ID
    let locationAuthorized: Bool
    @Binding var mapStyleIsStandard: Bool
    @Binding var showSymbols: Bool
    @Binding var showLookAroundPreview: Bool
    @Binding var show3D: Bool  // <-- NEW!

    var body: some View {
        HStack {
            if locationAuthorized {
                MapUserLocationButton(scope: mapScope)
            }

            // Custom 3D/2D toggle (cube icon)
            Button(action: { show3D.toggle() }) {
                Image(systemName: show3D ? "cube.fill" : "cube")
                    .font(.system(size: 18))
            }
            .padding(.horizontal)

            // Map style toggle
            Button(action: { mapStyleIsStandard.toggle() }) {
                Image(systemName: mapStyleIsStandard ? "map" : "map.fill")
                    .font(.system(size: 18))
            }
            .padding(.horizontal)

            // Show symbols toggle
            Button(action: { showSymbols.toggle() }) {
                Image(systemName: showSymbols ? "ellipsis.rectangle.fill" : "ellipsis.rectangle")
                    .font(.system(size: 18))
                    .padding([.top, .bottom], 8)
            }
            .padding(.horizontal)

            // LookAround preview toggle
            Button(action: { showLookAroundPreview.toggle() }) {
                Image(systemName: showLookAroundPreview ? "binoculars.fill" : "binoculars")
                    .font(.system(size: 18))
                    .padding([.top, .bottom], 8)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}
