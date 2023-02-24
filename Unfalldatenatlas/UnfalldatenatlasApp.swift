//
//  UnfalldatenatlasApp.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 22.01.23.
//

import SwiftUI

@main
struct UnfalldatenatlasApp: App {
    let persistenceController = PersistenceController.shared
    let viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
