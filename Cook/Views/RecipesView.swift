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
            List(selection: $selectedRecipe) {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(recipe.name ?? "") {
                        RecipeView(recipe: recipe)
                    }
                    .tag(recipe)
                }
                
                TextField("New Recipe", text: $newRecipeName)
                    .id("New Recipe")
                    .submitLabel(.done)
                    .focused($focused)
                    .onSubmit(submitNewRecipe)
            }
            .environment(\.editMode, .constant(picker ? .active : .inactive))
            .animation(.default, value: filteredRecipes)
            .navigationTitle("Recipes")
            .searchable(text: $text.animation())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        list.scrollTo("New Recipe")
                        focused = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
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
}
