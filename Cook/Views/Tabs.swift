//
//  Tabs.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

struct Tabs: View {
    @State var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlanView()
                .tag(1)
                .tabItem {
                    Label("Meal Plan", systemImage: "calendar")
                }
            
            NavigationView {
                RecipesView(selectedRecipe: .constant(nil), picker: false)
            }
            .tag(2)
            .tabItem {
                Label("Recipes", systemImage: "book.closed")
            }
            
            ListView(selectedTab: $selectedTab)
                .tag(3)
                .tabItem {
                    Label("Shopping List", systemImage: "list.bullet")
                }
        }
        .navigationViewStyle(.stack)
    }
}

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        Tabs()
    }
}
