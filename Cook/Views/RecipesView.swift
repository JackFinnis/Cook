//
//  RecipesView.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

struct RecipesView: View {
    @FetchRequest(sortDescriptors: []) var recipes: FetchedResults<Recipe>
    @Environment(\.managedObjectContext) var context
    @State var showNewRecipeView = false
    @State var newRecipeName = ""
    @State var showNewRecipeField = false
    @State var editMode = EditMode.inactive
    @State var selecting = EditMode.inactive
    @FocusState var focused: Bool
    @State var text = ""
    
    @Binding var selectedRecipe: Recipe?
    let picker: Bool
    
    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            guard text.isNotEmpty else { return true }
            return recipe.name?.localizedCaseInsensitiveContains(text) ?? false
        }.sorted { one, two in
            (one.lunches?.count ?? 0) + (one.suppers?.count ?? 0) >
            (two.lunches?.count ?? 0) + (two.suppers?.count ?? 0)
        }
    }
    
    var body: some View {
        ScrollViewReader { list in
            ZStack {
                List(selection: $selectedRecipe) {
                    ForEach(filteredRecipes) { recipe in
                        Row {
                            Text(recipe.name ?? "")
                            if !editMode.isEditing && !picker {
                                NavigationLink("") {
                                    RecipeView(recipe)
                                }
                            }
                        } trailing: {
                            DeleteButton(editMode: editMode) {
                                deleteRecipe(recipe)
                            }
                        }
                        .tag(recipe)
                    }
                    
                    if showNewRecipeField {
                        TextField("New Recipe", text: $newRecipeName)
                            .id("New Recipe")
                            .submitLabel(.done)
                            .focused($focused)
                            .onSubmit(submitNewRecipe)
                    }
                }
                .environment(\.editMode, $selecting)
                .animation(.default, value: filteredRecipes)
                .navigationTitle("Recipes")
                .searchable(text: $text.animation(), placement: .navigationBarDrawer)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack {
                            if !editMode.isEditing {
                                Button {
                                    withAnimation {
                                        showNewRecipeField = true
                                        list.scrollTo("New Recipe")
                                        focused = true
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                            if recipes.isNotEmpty {
                                EditButton(editMode: $editMode)
                            }
                        }
                        .animation(.none, value: editMode)
                    }
                }
                if recipes.isEmpty && !focused && !showNewRecipeField {
                    ErrorLabel("Add a recipe", systemName: "doc.text") {
                        showNewRecipeField = true
                        focused = true
                    }
                }
            }
        }
        .onAppear {
            selecting = picker ? .active : .inactive
            showNewRecipeField = recipes.isNotEmpty
        }
        .onChange(of: editMode) { editMode in
            withAnimation {
                selecting = picker && !editMode.isEditing ? .active : .inactive
            }
        }
    }
    
    func submitNewRecipe() {
        guard newRecipeName.isNotEmpty else { return }
        let recipe = Recipe(context: context)
        recipe.name = newRecipeName
        try? context.save()
        newRecipeName = ""
        focused = true
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        context.delete(recipe)
        try? context.save()
    }
}
