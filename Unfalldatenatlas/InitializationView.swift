//
//  InitializationView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 05.02.23.
//

import SwiftUI

struct InitializationView: View {
    @ObservedObject var viewModel: InitializationViewModel
    
    var body: some View {
        ProgressView(viewModel.initializationState.text, value: viewModel.progress, total: 1.0)
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//            .padding([.trailing], 5)
    }
}

//struct InitializationView_Previews: PreviewProvider {
//    static var previews: some View {
//        InitializationView()
//    }
//}
