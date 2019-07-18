//
//  DataController.swift
//  VirtualTourist
//
//  Created by Owais Gaffas on 01/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import CoreData

class DataController{
    static let instance = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "Virtual-Tourist")
    
    var viewContext : NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    func loadData() {
        persistentContainer.loadPersistentStores { (storeDesc, error) in
            if error != nil {
                fatalError(error!.localizedDescription)
            }
        }
    }
}

