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
    
//    @Environment(\.colorScheme) private var colorScheme // check if light or dark mode is active
    
#if os(macOS)
    let symbolFontSize: CGFloat = 22
#else
    let symbolFontSize: CGFloat = 17
#endif
    
    var body: some View {
        
#if targetEnvironment(macCatalyst)
        // Werte für macCatalyst
        let circleDiameter: CGFloat = isSelected ? 32 : 22
        let symbolFontSize: CGFloat = 24
#else
        // Werte für iOS
        let circleDiameter: CGFloat = isSelected ? 24 : 16
        let symbolFontSize: CGFloat = 17
#endif
        
        return ZStack {
            
            // Circle as center of the annotation
            Circle()
                .fill(accident.color)
//                .frame(width: isSelected ? 24 : 16, height: isSelected ? 24 : 16)
                .frame(width: circleDiameter, height: circleDiameter)
            
//                .stroke(accident.color, lineWidth: 5)
//                .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)

            // Symbol TextView only, when accident selected or generally symbols to be shown
            if isSelected || showSymbol {
                Text(accident.symbolString)
                    .font(.system(size: symbolFontSize))
                    .fixedSize()
//                    .background(Color.white)
                    .padding(2) // Optional für bessere Lesbarkeit

                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
//                    .offset(y: -20) // text on top of the circle
                    .offset(y: -(circleDiameter / 2 + 8))
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
