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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
