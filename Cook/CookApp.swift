//
//  CookApp.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

let NAME = "Just Cook"

@main
struct CookApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
