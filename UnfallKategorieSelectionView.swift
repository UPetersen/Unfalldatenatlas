//
//  UnfallKategorieSelectionView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 04.02.23.
//

import SwiftUI

struct UnfallKategorieSelectionView: View {
    
    @State private var selection = Set<String>()
        @State private var isEditMode: EditMode = .active

    @State private var landSelection = Set<Land>(Land.allCases.dropFirst())
    @ObservedObject var viewModel: ViewModel
        
        let items = [
            "Item 1",
            "Item 2",
            "Item 3",
            "Item 4"
        ]
    

        var body: some View {
            NavigationView {
                
//                List(items, id: \.self, selection: $selection) { name in
//                    Text(name)
//                }
                
            
                List(Land.allCases.dropFirst(), id: \.self, selection: $landSelection) { land in
                    Text(land.sectionText)
                }
                .onChange(of: landSelection, perform: { _ in print(landSelection.debugDescription)})
//                .toolbar {
//                    EditButton()
//                }
                .environment(\.editMode, self.$isEditMode)
            }
        }
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
}

//struct UnfallKategorieSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        UnfallKategorieSelectionView()
//    }
//}
