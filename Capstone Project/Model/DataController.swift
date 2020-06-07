//
//  DataController.swift
//  Capstone Project
//
//  Created by Robert Busby on 6/5/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init( modelName: String ) {
        persistentContainer = NSPersistentContainer( name: modelName )
    }
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load( completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores() { (storeDescription, error) in
            guard error == nil else {
                fatalError( error!.localizedDescription )
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

extension DataController {
    func autoSaveViewContext( interval: TimeInterval = 30 ) {
        // print( "autosaving...." )
        guard interval > 0 else {
            print( "Cannot set negative interval" )
            return
        }
        if viewContext.hasChanges {
            print( "Changes detected: autosaving..." )
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval ) {
            self.autoSaveViewContext( interval: interval )
        }
    }
}
