//
//  AccidentAnnotationView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 10.06.25.
//

import SwiftUI

struct AccidentAnnotationView: View {
    let accident: AccidentStructGRDB
    let showSymbol: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Circle as center of the annotation
            Circle()
                .fill(accident.color)
                .frame(width: isSelected ? 24 : 16, height: isSelected ? 24 : 16)
//                .stroke(accident.color, lineWidth: 5)
//                .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)

            // Symbol TextView only, when accident selected or generally symbols to be shown
            if isSelected || showSymbol {
                Text(accident.symbolString)
                    .font(.system(size: 17))
                    .fixedSize()
                    .background(Color.white)
                    .offset(y: -20) // text on top of the circle
            }
        }
        // Enlarge for larger tappable area (like padding)
        .frame(width: 44, height: 44, alignment: .center) // Apple recommends 44x44 for touch
        .contentShape(Rectangle()) // Taü area is rectangular
//        .background(Color.red.opacity(0.2)) // Only for debugging!
        .onTapGesture {
            onTap()
        }
    }
}
