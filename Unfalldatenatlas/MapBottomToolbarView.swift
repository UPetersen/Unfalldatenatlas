//
//  MapBottomToolbarView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 07.06.25.
//

import SwiftUI
import MapKit

/// A reusable toolbar displayed at the bottom of the map, providing controls for map type, user location, pitch, symbol visibility and look-around preview.
struct MapBottomToolbarView: View {
    /// Scope to control map interactions (e.g. pitch, user location).
    let mapScope: Namespace.ID
    
    /// Whether the app is authorized to access the user's location.
    let locationAuthorized: Bool
    
    /// Binding to toggle between standard and hybrid map styles.
    @Binding var mapStyleIsStandard: Bool
    
    /// Binding to toggle whether accident symbols (emojis) are shown.
    @Binding var showSymbols: Bool
    
    /// Binding to toggle the visibility of the LookAround preview.
    @Binding var showLookAroundPreview: Bool
    
    var body: some View {
        HStack {
            // Show user location button only if permission was granted
            if locationAuthorized {
                MapUserLocationButton(scope: mapScope)
            }
            
            // Toggle map pitch (2D / 3D)
            MapPitchToggle(scope: mapScope)
            
            // Button to switch between standard and hybrid map style
            Button(action: { mapStyleIsStandard.toggle() }) {
                Image(systemName: mapStyleIsStandard ? "map" : "map.fill")
                    .font(.system(size: 18)) // Fixed size (won’t scale with dynamic type)
            }
            .padding(.horizontal)
            
            // Button to toggle visibility of accident symbols (emojis)
            Button(action: { showSymbols.toggle() }) {
                Image(systemName: showSymbols ? "ellipsis.rectangle.fill" : "ellipsis.rectangle")
                    .font(.system(size: 18))
                    .padding([.top, .bottom], 8)
            }
            .padding(.horizontal)
            
            // Button to show/hide LookAround preview
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
