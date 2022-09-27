//
//  RecipeView.swift
//  Cook
//
//  Created by Jack Finnis on 26/09/2022.
//

import SwiftUI

struct RecipeView: View {
    @FetchRequest(sortDescriptors: []) var allIngredients: FetchedResults<Ingredient>
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var focused: Bool
    @State var editMode = EditMode.inactive
    @State var showEditRecipeView = false
    @State var newIngredientName = ""
    @State var name: String
    @State var ingredients: Set<Ingredient>
    
    @ObservedObject var recipe: Recipe
    
    init(_ recipe: Recipe) {
        self.recipe = recipe
        _name = State(initialValue: recipe.name ?? "")
        _ingredients = State(initialValue: Set(recipe.ingredients?.allObjects as? [Ingredient] ?? []))
    }
    
    var sortedIngredients: [Ingredient] {
        ingredients.sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .onChange(of: name, perform: saveName)
                .font(.system(size: 34).weight(.bold))
                .submitLabel(.done)
                .padding(.horizontal)
            
            Form {
                Section {
                    ForEach(sortedIngredients) { ingredient in
                        Text(ingredient.name ?? "")
                    }
                    .onDelete(perform: deleteIngredients)
                    
                    NavigationLink {
                        IngredientsView(selection: $ingredients)
                    } label: {
                        TextField("Ingredient", text: $newIngredientName)
                            .onSubmit(submitIngredient)
                            .focused($focused)
                            .submitLabel(.done)
                    }
                } header: {
                    Row {
                        Text("Ingredients")
                    } trailing: {
                        if sortedIngredients.isNotEmpty {
                            EditButton(editMode: $editMode)
                        }
                    }
                }
                .headerProminence(.increased)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: ingredients, perform: saveIngredients)
        .animation(.default, value: sortedIngredients)
        .environment(\.editMode, $editMode)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Delete", action: deleteRecipe)
                    .foregroundColor(.red)
            }
        }
    }
    
    func submitIngredient() {
        guard newIngredientName.isNotEmpty else { return }
        let newIngredient: Ingredient
        if let ingredient = allIngredients.first(where: { $0.name == newIngredientName }) {
            newIngredient = ingredient
        } else {
            let ingredient = Ingredient(context: context)
            ingredient.name = newIngredientName
            try? context.save()
            newIngredient = ingredient
        }
        ingredients.insert(newIngredient)
        newIngredientName = ""
        focused = true
    }
    
    func saveIngredients(_ ingredients: Set<Ingredient>) {
        recipe.removeFromIngredients(recipe.ingredients ?? [])
        for ingredient in ingredients {
            recipe.addToIngredients(ingredient)
        }
        try? context.save()
    }
    
    func saveName(_ name: String) {
        recipe.name = name
        try? context.save()
    }
    
    func deleteIngredients(at offsets: IndexSet) {
        for index in offsets {
            let ingredient = sortedIngredients[index]
            ingredients.remove(ingredient)
        }
    }
    
    func deleteRecipe() {
        context.delete(recipe)
        try? context.save()
        dismiss()
    }
}
