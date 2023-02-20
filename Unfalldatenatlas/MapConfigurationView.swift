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
    
    var body: some View {

        VStack() {
            Button(action: {
                if mapType == .standard {
                    mapType = .hybrid
                } else {
                    mapType = .standard
                }
            }) {
                Image(systemName: "map.fill")
                    .padding([.top, .bottom], 8)
//                    .padding([.trailing, .leading], 2)
            }
//            Divider()
//            Button(action: {}) {
//                Image(systemName: "location")
//                    .padding()
//            }

        }
        .foregroundColor(.secondary)
        .buttonStyle(.bordered)
        .padding([.trailing], 10)
//        .background(Color(.red))
//        .tint(Color(.secondaryLabel))
//        .tint(Color(.red))

    }
    
}


//struct MapConfigurationView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        MapConfigurationView()
//    }
//}
