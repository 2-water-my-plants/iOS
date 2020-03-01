//
//  CoreDataStack.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/1/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}
    
    // Creates Persistent Store Manager and loads Persistent Stores
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WaterMyPlant")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var saveError: Error?
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        
        if let error = saveError { throw error }
    }
}
