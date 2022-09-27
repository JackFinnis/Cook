//
//  CookApp.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

@main
struct CookApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            Tabs()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
