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
        VStack(spacing: 2) {
            // Symbol-TextView nur, wenn selektiert oder Modus aktiv
            if isSelected || showSymbol {
                Text(accident.symbolString)
                    .font(.system(size: 17))
                    .fixedSize()
                    .background(Color.white)
            }
            
            Circle()
                .fill(accident.color)
                .frame(width: isSelected ? 24 : 16, height: isSelected ? 24 : 16)
        }
        // 👇 unsichtbar größer machen für besseres Tap-Ziel
        .frame(width: 44, height: 44, alignment: .center) // Apple empfiehlt 44x44 für Touch
        .contentShape(Rectangle()) // wichtig: Tap-Fläche ist jetzt rechteckig (nicht nur Circle)
//        .background(Color.red.opacity(0.2)) // Nur zum Debuggen!
        .onTapGesture {
            onTap()
        }
    }
    
    
}
