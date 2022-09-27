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
    @State var showDeleteConfirmation = false
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
                .font(.system(size: 34).weight(name.isEmpty ? .regular : .bold))
                .submitLabel(.done)
                .padding(.horizontal)
            
            Form {
                Section {
                    ForEach(sortedIngredients) { ingredient in
                        Row {
                            Text(ingredient.name ?? "")
                        } trailing: {
                            DeleteButton(editMode: editMode) {
                                removeIngredient(ingredient)
                            }
                        }
                        .swipeActions {
                            Button("Remove", role: .destructive) {
                                removeIngredient(ingredient)
                            }
                        }
                    }
                    
                    if !editMode.isEditing {
                        NavigationLink {
                            IngredientsView(selection: $ingredients)
                        } label: {
                            TextField("Add Ingredient", text: $newIngredientName)
                                .onSubmit(submitIngredient)
                                .focused($focused)
                                .submitLabel(.done)
                        }
                    }
                } header: {
                    Text(ingredients.formattedPlural("Ingredient"))
                }
                .headerProminence(.increased)
                
                if editMode.isEditing {
                    Button("Delete") {
                        showDeleteConfirmation = true
                    }
                    .horizontallyCentred()
                    .foregroundColor(.red)
                    .confirmationDialog("", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
                        Button("Delete", role: .destructive, action: deleteRecipe)
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: ingredients, perform: saveIngredients)
        .animation(.default, value: sortedIngredients)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton(editMode: $editMode)
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

    func removeIngredient(_ ingredient: Ingredient) {
        ingredients.remove(ingredient)
    }
    
    func deleteRecipe() {
        context.delete(recipe)
        try? context.save()
        Haptics.tap()
        dismiss()
    }
}
