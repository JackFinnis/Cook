//
//  Tabs.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

struct Tabs: View {
    var body: some View {
        TabView {
            PlanView()
                .tabItem {
                    Label("Meal Plan", systemImage: "calendar")
                }
            
            NavigationView {
                RecipesView(selectedRecipe: .constant(nil), picker: false)
            }
            .tabItem {
                Label("Recipes", systemImage: "book.closed")
            }
        }
    }
}

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        Tabs()
    }
}
