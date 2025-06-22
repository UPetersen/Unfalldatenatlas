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
    let isfetchingSelectedCountInRegion: Bool
    let selectedCountInRegion: Int     // viewModel.selectedCountInRegion

    let mapCamera: MapCamera?
    let mapStyleIsStandard: Bool
    let mapScope: Namespace.ID

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .bottom) {
                Spacer()
                
                if isFetchingAccidents || isfetchingSelectedCountInRegion {
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

        guard mapStyleIsStandard,
              let mapCamera,
              (mapCamera.heading < 0.5 || mapCamera.heading > 355.5),
              mapCamera.pitch <= 0.5 else {
            return "Unfallzahl für Kartenausschnitt nur bei Standardkarte in Nordausrichtung"
        }

        if selectedCountInRegion > countOfAccidents {
            return "\(selectedCountInRegion) Unfälle im Kartenausschnitt (\(countOfAccidents) angezeigt)"
        } else {
            return "\(countOfAccidents) Unfälle im Kartenausschnitt"
        }

//        // More precise information on the four different possible states. Overall too nervous, thus not used.
//        if isFetchingAccidents && !isfetchingSelectedCountInRegion { // 1
//            return "\(countOfAccidents) Unfälle im Kartenausschnitt"
//        } else if !isFetchingAccidents && isfetchingSelectedCountInRegion && countOfAccidents < 400 { // 2
//            return "\(countOfAccidents) Unfälle im Kartenausschnitt"
//        } else if !isFetchingAccidents && isfetchingSelectedCountInRegion && countOfAccidents >= 400  { // 3
//            return " Unfälle im Kartenausschnitt (\(countOfAccidents) angezeigt)"
//        } else { // 4
//            return "\(selectedCountInRegion) Unfälle im Kartenausschnitt (\(countOfAccidents) angezeigt)"
//        }

    }
    
    
}
