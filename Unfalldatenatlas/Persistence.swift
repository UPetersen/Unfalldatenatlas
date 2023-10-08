//
//  Persistence.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 22.01.23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
//    static let shared = PersistenceController(inMemory: true)

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Unfalldatenatlas")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        } else {
//            container.persistentStoreDescriptions.first!.type = NSBinaryStoreType
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
//        print("UndoManager can undo: \(container.viewContext.undoManager?.canUndo), can redo: \(container.viewContext.undoManager?.canUndo)")
//        let hugo = container.managedObjectModel.entities.first!.attributesByName
//        print("\(container.managedObjectModel.entities.first?.indexes.description)")
    }
}
