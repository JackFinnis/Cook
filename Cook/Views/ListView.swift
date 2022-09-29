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
    @State var selectedIngredient: Ingredient?
    @State var newIngredientName = ""
    @State var animate = false
    @State var showRecipesView = false
    @State var showIngredientsView = false
    @State var selectedRecipe: Recipe?
    
    @Binding var selectedTab: Int
    let filteredDays: [Day]
    let justSuppers: Bool
    
    var list: ShoppingList? { lists.first }
    
    var sortedIngredients: [Ingredient] {
        ingredients.sorted { one, two in
            one.name ?? "" < two.name ?? ""
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
            .filter { !self.ingredients.contains($0) }
            .sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { list in
                List(selection: $selectedIngredient) {
                    Section {
                        ForEach(sortedIngredients, id: \.self) { ingredient in
                            Text(ingredient.name ?? "")
                                .tag(ingredient)
                        }
                        
                        TextField("Add Item", text: $newIngredientName)
                            .id(0)
                            .onSubmit(submitIngredient)
                            .submitLabel(.done)
                            .focused($focused)
                            .onChange(of: newIngredientName) { _ in
                                withAnimation {
                                    list.scrollTo(0)
                                }
                            }
                    } header: {
                        Row {
                            Text(ingredients.formattedPlural("Item"))
                                .animation(.none, value: ingredients)
                        } trailing: {
                            Menu("Add Ingredients") {
                                Button {
                                    showRecipesView = true
                                } label: {
                                    Label("From recipe", systemImage: "book")
                                }
                                Button {
                                    showIngredientsView = true
                                } label: {
                                    Label("Browse", systemImage: "magnifyingglass")
                                }
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
                                        .navigationTitle(ingredients.formattedPlural("Ingredient"))
                                }
                                .hidden()
                            }
                        }
                    }
                    .headerProminence(.increased)
                    
                    Section {
                        ForEach(filteredIngredientsNeeded) { ingredient in
                            Text(ingredient.name ?? "")
                                .tag(ingredient)
                        }
                    } header: {
                        if ingredientsNeeded.isEmpty {
                            ErrorLabel("Make a plan", systemName: "calendar") {
                                selectedTab = 1
                            }
                            .horizontallyCentred()
                        } else {
                            Text(filteredIngredientsNeeded.isEmpty ? "Ready for this week" : "Needed this week")
                                .animation(.none)
                        }
                    }
                    .headerProminence(.increased)
                }
                .environment(\.editMode, .constant(.active))
                .animation(animate ? .default : .none, value: sortedIngredients)
                .animation(animate ? .default : .none, value: filteredIngredientsNeeded)
                .navigationTitle("Shopping List")
                .onAppear(perform: updateList)
                .onChange(of: selectedIngredient, perform: newSelectedIngredient)
                .onChange(of: ingredients, perform: saveIngredients)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation {
                                list.scrollTo(0)
                                focused = true
                            }
                        } label: {
                            Image(systemName: "plus")
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
        list?.removeFromIngredients(list?.ingredients ?? [])
        for ingredient in ingredients {
            list?.addToIngredients(ingredient)
        }
        try? context.save()
    }
    
    func newSelectedIngredient(_ newSelectedIngredient: Ingredient?) {
        if let newSelectedIngredient {
            if ingredients.contains(newSelectedIngredient) {
                ingredients.remove(newSelectedIngredient)
                Haptics.tap()
            } else {
                ingredients.insert(newSelectedIngredient)
            }
            self.selectedIngredient = nil
        }
    }
    
    func updateList() {
        let list = list ?? ShoppingList(context: context)
        if ingredients.isEmpty {
            ingredients = Set(list.ingredients?.allObjects as? [Ingredient] ?? [])
        }
        context.refreshAllObjects()
        animate = true
        try? context.save()
    }
}
