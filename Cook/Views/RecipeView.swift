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
    @State var name = ""
    @State var animate = false
    @State var ingredients = Set<Ingredient>()
    @State var type = RecipeType.meal
    @State var speed = Speed.medium
    
    @ObservedObject var recipe: Recipe
    
    var sortedIngredients: [Ingredient] {
        ingredients.sorted { one, two in
            one.name ?? "" < two.name ?? ""
        }
    }
    
    var body: some View {
        ScrollViewReader { form in
            VStack {
                VStack {
                    TextField("Name", text: $name)
                        .onChange(of: name, perform: saveName)
                        .font(.system(size: 34).weight(name.isEmpty ? .regular : .bold))
                        .submitLabel(.done)
                    
                    Picker("Recipe Type", selection: $type) {
                        ForEach(RecipeType.allCases, id: \.self) { type in
                            Text(type.name)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type, perform: saveType)
                    
                    Picker("Recipe Speed", selection: $speed) {
                        ForEach(Speed.sorted, id: \.self) { speed in
                            Text(speed.name)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: speed, perform: saveSpeed)
                    
                    Row {
                        Text(ingredients.formattedPlural("Ingredient"))
                            .animation(.none, value: ingredients)
                            .font(.title2.weight(.semibold))
                    } trailing: {
                        if !editMode.isEditing {
                            Button {
                                withAnimation {
                                    focused = true
                                    form.scrollTo("Add Ingredient")
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.top)
                }
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
                                    .navigationTitle(ingredients.formattedPlural("Ingredient"))
                            } label: {
                                TextField("Add Ingredient", text: $newIngredientName)
                                    .id("Add Ingredient")
                                    .onSubmit(submitIngredient)
                                    .focused($focused)
                                    .submitLabel(.done)
                                    .onChange(of: newIngredientName) { _ in
                                        withAnimation {
                                            form.scrollTo("Add Ingredient")
                                        }
                                    }
                            }
                        }
                    }
                    
                    if editMode.isEditing {
                        Section {
                            Button("Delete") {
                                showDeleteConfirmation = true
                            }
                            .horizontallyCentred()
                            .foregroundColor(.red)
                            .confirmationDialog("", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
                                Button("Delete Recipe", role: .destructive, action: deleteRecipe)
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: ingredients, perform: saveIngredients)
        .animation(animate ? .default : .none, value: sortedIngredients)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = recipe.name ?? ""
            type = RecipeType(rawValue: recipe.type) ?? .meal
            ingredients = Set(recipe.ingredients?.allObjects as? [Ingredient] ?? [])
        }
        .task {
            animate = true
        }
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
        guard name.isNotEmpty else { return }
        recipe.name = name
        try? context.save()
    }
    
    func saveType(_ type: RecipeType) {
        recipe.type = type.rawValue
        try? context.save()
    }
    
    func saveSpeed(_ speed: Speed) {
        recipe.speed = speed.rawValue
        try? context.save()
    }
    
    func removeIngredient(_ ingredient: Ingredient) {
        ingredients.remove(ingredient)
    }
    
    func deleteRecipe() {
        context.delete(recipe)
        try? context.save()
        Haptics.success()
        dismiss()
    }
}
