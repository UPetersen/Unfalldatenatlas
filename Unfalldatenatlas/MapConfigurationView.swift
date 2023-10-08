//
//  MapConfigurationView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 19.02.23.
//

import SwiftUI
import MapKit

struct MapConfigurationView: View {
    
    @Binding var mapType: MKMapType
    @Binding var showSymbols: Bool
    @Binding var moveToCurrentLocation: Bool
    var showLocationButton: Bool = false
    
    var body: some View {

        VStack() {
            // Button to move to current location
            if showLocationButton {
                Button(action: { moveToCurrentLocation.toggle() }) {
                    Image(systemName: "location").padding([.top, .bottom], 8)
                }
                .padding(.horizontal, 12)

                Divider().overlay(Color(.secondaryLabel)).frame(height: 5) //            Divider().overlay(Color(.tertiaryLabel)).frame(height: 5)
            }
            
            // Button to switch between standard and satellite map
            Button(action: { mapType = mapType == .standard ? .hybrid : .standard }) {
                Image(systemName: mapType == .standard ? "map" : "map.fill").padding([.top, .bottom], 8)
            }
            .padding(.horizontal, 12)

            Divider().overlay(Color(.secondaryLabel)).frame(height: 5) //            Divider().overlay(Color(.tertiaryLabel)).frame(height: 5)
            
            // Button to toggle showing symbols for the accidents or not
            Button(action: { showSymbols.toggle() }) {
                Image(systemName: showSymbols ? "ellipsis.circle.fill" : "ellipsis.circle").padding([.top, .bottom], 8)
            }
            .padding(.horizontal, 12)

        }
        .padding(.vertical, 10)
        .fixedSize(horizontal: true, vertical: false)
        .foregroundColor(.secondary)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding([.trailing], 5)
    }
}

//struct MapConfigurationView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        MapConfigurationView()
//    }
//}
