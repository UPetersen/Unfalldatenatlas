//
//  LookAroundPreviewContainer.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 03.06.25.
//

import SwiftUI
import MapKit

/// A container view that displays Apple's Look Around preview,
/// including fallback text and a close button overlay.
struct LookAroundPreviewContainer: View {
    let scene: MKLookAroundScene?
    let selectedAccident: AccidentStructGRDB?
    @Binding var isVisible: Bool
    
    var body: some View {
        LookAroundPreview(initialScene: scene)
            .frame(height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay {
                /// Fallback overlay if scene is not available or nothing is selected
                if scene == nil || selectedAccident == nil {
                    Text("Keine Lookaround-Ansicht vorhanden,\nkein Unfall ausgewählt oder \nInternetverbindung eingeschränkt.")
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
            }
            .overlay {
                /// X button to close the preview
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Button(action: {
                            isVisible = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .background(Color.white)
                                .clipShape(Circle())
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        }
                        .padding(.trailing, 15)
                        .padding(.top, 10)
                        Spacer()
                    }
                }
            }
    }
}
