//
//  CookApp.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

let NAME = "Just Cook"
let EMAIL = "hoverbug@btinternet.com"
let WEBSITE = URL(string: "https://hoverbug.wixsite.com/website")!
let APP_URL = URL(string: "https://apps.apple.com/app/id6443628020")!

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
