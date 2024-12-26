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

//    static var preview: PersistenceController = {
//        let result = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return result
//    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        
        print("1.) Init of PersistenceController at time \(Date.now.formatted(date: .complete, time: .complete))")
        container = NSPersistentContainer(name: "Unfalldatenatlas")
        print("2.) Init of PersistenceController at time \(Date.now.formatted(date: .complete, time: .complete))")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        let storeURL = container.persistentStoreDescriptions.first!.url!
        if requiresMigration(storeURL: storeURL) {
            deleteStore(storeURL: storeURL)
        }

        // Defer lightweight migration
        //        let storeDescription = NSPersistentStoreDescription()
        //        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreDeferredLightweightMigrationOptionKey)
        //        storeDescription.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        //        storeDescription.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        //        storeDescription.url = container.persistentStoreDescriptions.first?.url
        //        container.persistentStoreDescriptions = [storeDescription]
        //        print("Container's store descriptions: \(container.persistentStoreDescriptions)")
        
        // Add store asynchronously
//        let storeDescription = NSPersistentStoreDescription()
//        storeDescription.shouldAddStoreAsynchronously = true
//        storeDescription.url = container.persistentStoreDescriptions.first?.url
//        container.persistentStoreDescriptions = [storeDescription]
//        print("Container's store descriptions: \(container.persistentStoreDescriptions)")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("3.) Init of PersistenceController at time \(Date.now.formatted(date: .complete, time: .complete))")
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
            
//            print("Container's store descriptions in completion handler: \(storeDescription.description)")
//            print("Stores options: \(storeDescription.options.description)")
            
//            NotificationCenter.default.post(name: Notification.Name("didFinishLoadingStores"), object: nil)
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        print("5.) Init of PersistenceController at time \(Date.now.formatted(date: .complete, time: .complete))")
        
        //        print("UndoManager can undo: \(container.viewContext.undoManager?.canUndo), can redo: \(container.viewContext.undoManager?.canUndo)")
        //        let hugo = container.managedObjectModel.entities.first!.attributesByName
        //        print("\(container.managedObjectModel.entities.first?.indexes.description)")
        
        //        NotificationCenter.default.post(name: Notification.Name("didFinishLoadingStores"), object: nil)
    }
    
//    func requiresMigration(storeURL: URL) -> Bool {
//        let sourceMetadata = try! NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL)
//        let destinationModel = container.managedObjectModel
//        return !destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)
//    }
    
    func requiresMigration(storeURL: URL) -> Bool {
        do {
            let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL)
            let destinationModel = container.managedObjectModel
            return !destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)
        } catch {
            print("Failed to receive store metadata: \(error)")
            return false
        }
    }

    func deleteStore(storeURL: URL) {
        let fileManager = FileManager.default

        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(
                at: storeURL,
                ofType: NSSQLiteStoreType,
                options: nil
            )
            print("Destroyed store at \(storeURL) at \(Date()).")
            try fileManager.removeItem(at: storeURL)
            print("Removed store at \(storeURL) at \(Date()).")
        } catch {
            fatalError("Failed to delete persistent store: \(error)")
        }
    }
}


//        // Document Directory
//        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            print("Documents Directory: \(documentDirectory)")
//        }
//
//        // Caches Directory
//        if let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
//            print("Caches Directory: \(cachesDirectory)")
//        }
//
//        // Application Support Directory
//        if let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
//            print("Application Support Directory: \(appSupportDirectory)")
//        }
//
//        func listFilesInApplicationDirectory() {
//            let fileManager = FileManager.default
//            if let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
//                do {
//                    let directoryContents = try fileManager.contentsOfDirectory(at: appSupportDirectory, includingPropertiesForKeys: nil)
//                    for fileURL in directoryContents {
//                        print(fileURL.lastPathComponent)
//                    }
//                } catch {
//                    print("Error reading contents of Application Support Directory: \(error)")
//                }
//            }
//        }
//        // Beispielnutzung
//        listFilesInApplicationDirectory()
//        // Der Pfad zu deinem Core Data-Modell im Bundle
//        if let modelURL = Bundle.main.url(forResource: "YourModelName", withExtension: "momd") {
//            print("Model URL: \(modelURL)")
//        } else {
//            print("Model not found")
//        }

// Deferred Lightweight migration
//        let store = PersistenceController.shared.container.persistentStoreCoordinator.persistentStores.first!
//        let key = NSPersistentStoreDeferredLightweightMigrationOptionKey
//        print("Stores options: \(store.options?.description ?? "No options")")
//        print("Stores metadata: \(store.metadata.description)")
//        if let hasMigration = store.metadata[key], hasMigration as? Bool == true {
//            print("Starting lightweight migration at \(Date.now)")
//            try? PersistenceController.shared.container.persistentStoreCoordinator.finishDeferredLightweightMigrationTask()
//            print("Finished with lightweight migration at \(Date.now)")
////            PersistenceController.shared.container.performBackgroundTask() { context in
////                print("Starting lightweight migration in the background")
////                try? PersistenceController.shared.container.persistentStoreCoordinator.finishDeferredLightweightMigration()
////                print("Finished with lightweight migration in the background")
////            }
//        }


