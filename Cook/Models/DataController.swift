//
//  ViewModel.swift
//  Cook
//
//  Created by Jack Finnis on 26/09/2022.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Model")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error {
                debugPrint(error)
            }
        }
    }
}
