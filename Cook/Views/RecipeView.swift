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
    @State var showEditRecipeView = false
    @State var newIngredientName = ""
    @State var appeared = false
    @State var name = ""
    @State var ingredients = Set<Ingredient>()
    
    @ObservedObject var recipe: Recipe
    
    var sortedIngredients: [Ingredient] {
        ingredients.sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var body: some View {
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
                TextField("Name", text: $name)
                    .onChange(of: name, perform: { _ in saveName() })
                    .font(.system(size: 34).weight(.bold))
                    .submitLabel(.done)
            }
            .headerProminence(.increased)
        }
        .animation(.default, value: newIngredientName)
        .environment(\.editMode, .constant(.active))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Delete", action: deleteRecipe)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            if !appeared {
                appeared = true
                name = recipe.name ?? ""
                ingredients = Set(recipe.ingredients?.allObjects as? [Ingredient] ?? [])
            } else {
                saveIngredients()
            }
        }
    }
    
    func submitIngredient() {
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
        saveIngredients()
        focused = true
    }
    
    func saveIngredients() {
        Task {
            DispatchQueue.main.async {
                recipe.removeFromIngredients(recipe.ingredients ?? [])
                for ingredient in ingredients {
                    recipe.addToIngredients(ingredient)
                }
            }
        }
    }
    
    func saveName() {
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
