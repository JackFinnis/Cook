//
//  ListView.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var lists: FetchedResults<ShoppingList>
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day>
    @State var ingredients = Set<Ingredient>()
    var list: ShoppingList? { lists.first }
    
    @Binding var selectedTab: Int
    
    var sortedIngredients: [Ingredient] {
        ingredients.sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var filteredDays: [Day] {
        days.filter { day in
            day.date ?? .distantPast >= Date.now.startOfDay
        }
    }
    
    var ingredientsNeeded: [Ingredient] {
        var ingredients = [Ingredient]()
        for day in filteredDays {
            ingredients.append(contentsOf: day.lunch?.ingredients?.allObjects as? [Ingredient] ?? [])
            ingredients.append(contentsOf: day.supper?.ingredients?.allObjects as? [Ingredient] ?? [])
        }
        return Array(Set(ingredients))
    }
    
    var filteredIngredientsNeeded: [Ingredient] {
        ingredientsNeeded
            .filter { !self.ingredients.contains($0) }
            .sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(sortedIngredients) { ingredient in
                        ListRow(ingredient: ingredient, ingredients: $ingredients, list: list)
                    }
                    
                    Section {
                        ForEach(filteredIngredientsNeeded) { ingredient in
                            ListRow(ingredient: ingredient, ingredients: $ingredients, list: list)
                        }
                    } header: {
                        if filteredIngredientsNeeded.isNotEmpty {
                            Text("Needed this week")
                        }
                    }
                    .headerProminence(.increased)
                }
                if ingredientsNeeded.isEmpty {
                    ErrorLabel("Make a plan", systemName: "calendar") {
                        selectedTab = 1
                    }
                }
            }
            .navigationTitle("Shopping List")
            .onAppear(perform: updateList)
        }
    }
    
    func updateList() {
        let list = list ?? ShoppingList(context: context)
        for ingredient in list.ingredients?.allObjects as? [Ingredient] ?? [] {
            ingredients.insert(ingredient)
        }
        try? context.save()
        context.refreshAllObjects()
    }
}
