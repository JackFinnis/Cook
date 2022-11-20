//
//  ListView.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var allIngredients: FetchedResults<Ingredient>
    @FetchRequest(sortDescriptors: []) var lists: FetchedResults<ShoppingList>
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day>
    @FocusState var focused: Bool
    @State var ingredients = Set<Ingredient>()
    @State var newIngredientName = ""
    @State var animate = false
    @State var showRecipesView = false
    @State var showIngredientsView = false
    @State var selectedRecipe: Recipe?
    @State var justDeletedIngredient: Ingredient?
    @State var recentlyRemoved = [Ingredient]()
    
    @Binding var selectedTab: Int
    let filteredDays: [Day]
    let justSuppers: Bool
    
    var list: ShoppingList? { lists.first }
    
    var sortedIngredients: [Ingredient] {
        ingredients.filter { ($0.name ?? "").isNotEmpty }
            .sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var filteredFavourites: [Ingredient] {
        allIngredients.filter { ingredient in
            !ingredients.contains(ingredient) && ingredient.favourite
        }
    }
    
    var ingredientsNeeded: [Ingredient] {
        var ingredients = [Ingredient]()
        for day in filteredDays {
            ingredients.append(contentsOf: day.supper?.ingredients?.allObjects as? [Ingredient] ?? [])
            if !justSuppers {
                ingredients.append(contentsOf: day.lunch?.ingredients?.allObjects as? [Ingredient] ?? [])
            }
        }
        return Array(Set(ingredients))
    }
    
    var filteredIngredientsNeeded: [Ingredient] {
        ingredientsNeeded
            .filter { !ingredients.contains($0) }
            .sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { list in
                List {
                    ForEach(sortedIngredients, id: \.self) { ingredient in
                        HStack {
                            Button {
                                justDeletedIngredient = ingredient
                                recentlyRemoved.append(ingredient)
                                Haptics.tap()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    ingredients.remove(ingredient)
                                }
                            } label: {
                                let justDeleted = justDeletedIngredient == ingredient
                                Image(systemName: justDeleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(justDeleted ? .accentColor : Color(uiColor: .placeholderText))
                                    .font(.title2)
                            }
                            Text(ingredient.name ?? "")
                        }
                    }
                    
                    TextField("Add Item", text: $newIngredientName)
                        .id(0)
                        .onSubmit(submitIngredient)
                        .submitLabel(.done)
                        .focused($focused)
                    
                    Section {
                        ForEach(filteredIngredientsNeeded) { ingredient in
                            Row {
                                Text(ingredient.name ?? "")
                            } trailing: {
                                Button {
                                    ingredients.insert(ingredient)
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                }
                            }
                        }
                    } header: {
                        if ingredientsNeeded.isEmpty {
                            ErrorLabel("Make a plan", systemName: "calendar") {
                                selectedTab = 1
                            }
                            .horizontallyCentred()
                        } else {
                            Row {
                                Text(filteredIngredientsNeeded.isEmpty ? "Ready for this week" : "Needed this week")
                                    .animation(.none)
                            } trailing: {
                                if filteredIngredientsNeeded.isNotEmpty {
                                    Button("Add All") {
                                        for ingredient in filteredIngredientsNeeded {
                                            ingredients.insert(ingredient)
                                        }
                                    }
                                    .font(.body)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                    
//                    if filteredFavourites.isNotEmpty {
//                        Section("Favourites") {
//                            ForEach(filteredFavourites) { ingredient in
//                                IngredientRow(ingredient: ingredient, selection: $ingredients, editMode: .inactive)
//                            }
//                        }
//                        .headerProminence(.increased)
//                    }
                }
                .listStyle(.insetGrouped)
                .animation(animate ? .default : .none, value: ingredients)
                .navigationTitle("Shopping List")
                .onAppear(perform: updateList)
                .onChange(of: ingredients, perform: saveIngredients)
                .overlay(alignment: .bottom) {
                    Text(sortedIngredients.count.formattedPlural("item"))
                        .animation(.none, value: ingredients)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(10)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if let recent = recentlyRemoved.last {
                            Button {
                                ingredients.insert(recent)
                                recentlyRemoved.removeAll { $0.name == recent.name }
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                withAnimation {
                                    list.scrollTo(0)
                                    focused = true
                                }
                            } label: {
                                Label("Add Item", systemImage: "pencil")
                            }
                            Button {
                                showRecipesView = true
                            } label: {
                                Label("From a Recipe", systemImage: "book")
                            }
                            Button {
                                showIngredientsView = true
                            } label: {
                                Label("Browse Ingredients", systemImage: "magnifyingglass")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .font(.body)
                        .overlay {
                            NavigationLink("", isActive: $showRecipesView) {
                                RecipesView(selectedRecipe: $selectedRecipe, picker: true)
                            }
                            .hidden()
                            .onChange(of: selectedRecipe, perform: didSelectRecipe)
                            
                            NavigationLink("", isActive: $showIngredientsView) {
                                IngredientsView(selection: $ingredients)
                            }
                            .hidden()
                        }
                    }
                }
            }
        }
    }
    
    func submitIngredient() {
        let name = newIngredientName.trimmingCharacters(in: .whitespaces)
        guard name.isNotEmpty else { newIngredientName = ""; return }
        
        let newIngredient: Ingredient
        if let ingredient = allIngredients.first(where: { $0.name == name }) {
            newIngredient = ingredient
        } else {
            let ingredient = Ingredient(context: context)
            ingredient.name = name
            try? context.save()
            newIngredient = ingredient
        }
        ingredients.insert(newIngredient)
        newIngredientName = ""
        focused = true
    }
    
    func didSelectRecipe(_ recipe: Recipe?) {
        if let recipe {
            for ingredient in recipe.ingredients?.allObjects as? [Ingredient] ?? [] {
                ingredients.insert(ingredient)
            }
            selectedRecipe = nil
            Haptics.tap()
        }
    }
    
    func saveIngredients(ingredients: Set<Ingredient>) {
        justDeletedIngredient = nil
        list?.removeFromIngredients(list?.ingredients ?? [])
        for ingredient in ingredients {
            list?.addToIngredients(ingredient)
        }
        try? context.save()
    }
    
//    func newSelectedIngredient(_ newSelectedIngredient: Ingredient?) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if let newSelectedIngredient {
//                if ingredients.contains(newSelectedIngredient) {
//                    ingredients.remove(newSelectedIngredient)
//                    Haptics.tap()
//                } else {
//                    ingredients.insert(newSelectedIngredient)
//                }
//            }
//            if self.selectedIngredient == newSelectedIngredient {
//                self.selectedIngredient = nil
//            }
//        }
//    }
    
    func updateList() {
        let list = list ?? ShoppingList(context: context)
        try? context.save()
        context.refreshAllObjects()
        if ingredients.isEmpty {
            ingredients = Set(list.ingredients?.allObjects as? [Ingredient] ?? [])
        }
        animate = true
    }
}
