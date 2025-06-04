//
//  AccidentMapOverlayView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 02.06.25.
//
import SwiftUI
//import MapKit
@preconcurrency import MapKit

//// Overlay with text on number of accidents within region and number of accidents displayed and compass.
struct AccidentMapOverlayView: View {
    let isFetchingAccidents: Bool
    let countOfAccidents: Int          // viewModel.accidentStructsGRDB.count
    let selectedCountInRegion: Int     // viewModel.selectedCountInRegion
    let mapCamera: MapCamera?
    let mapStyleIsStandard: Bool
    let mapScope: Namespace.ID

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .bottom) {
                Spacer()
                if isFetchingAccidents {
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

            HStack {
                Spacer()
                MapCompass(scope: mapScope)  // kein `scope` notwendig
                    .padding(.horizontal)
            }

//#if DEBUG
//            if let regionAreaText {
//                Text(regionAreaText)
//            }
//#endif
        }
    }
    
    var infoTextForRegion: String {
        var text: String = "Error or no value."
                
        if let mapCamera, !mapStyleIsStandard  || (0.5 < mapCamera.heading && mapCamera.heading < 355.5) || 0.5 < mapCamera.pitch {
            // Camera is not standard map, not in north or pitch is no zero (not in 2D) -> no count information in visible region since not accurate
            text = "Unfallzahl für Kartenausschnitt nur bei Standardkarte in Nordausrichtung"
        } else {
            if selectedCountInRegion > countOfAccidents {
                text = "\(selectedCountInRegion) Unfälle im Kartenausschnitt (\(countOfAccidents) angezeigt)"
            } else {
                text = "\(countOfAccidents) Unfälle im Kartenausschnitt"
            }
        }
        return text
    }
    
    
    
}
