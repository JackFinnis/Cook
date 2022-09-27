//
//  Tabs.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day>
    @State var repeatEvery = Repeat(weeks: UserDefaults.standard.integer(forKey: "repeatEvery"))
    @State var justSuppers = UserDefaults.standard.bool(forKey: "justSuppers")
    @State var editMode = EditMode.inactive
    @State var selectedTab = 1
    
    var filteredDays: [Day] {
        days.filter { day in
            day.date ?? .distantPast >= Date.now.startOfDay
        }.sorted { one, two in
            one.date ?? .now < two.date ?? .now
        }
    }
    
    var empty: Bool {
        filteredDays.reduce(true) { $0 && (justSuppers ? true : $1.lunch == nil) && $1.supper == nil }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlanView(justSuppers: $justSuppers, repeatEvery: $repeatEvery, filteredDays: filteredDays, empty: empty)
                .tag(1)
                .tabItem {
                    Label("Meal Plan", systemImage: "calendar")
                }
            
            NavigationView {
                RecipesView(selectedRecipe: .constant(nil), picker: false)
            }
            .tag(2)
            .tabItem {
                Label("Recipes", systemImage: "book")
            }
            
            ListView(selectedTab: $selectedTab, filteredDays: filteredDays, justSuppers: justSuppers)
                .tag(3)
                .tabItem {
                    Label("Shopping List", systemImage: "list.bullet")
                }
        }
        .navigationViewStyle(.stack)
    }
}
