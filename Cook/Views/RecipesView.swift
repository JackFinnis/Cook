//
//  RecipesView.swift
//  Cook
//
//  Created by Jack Finnis on 25/09/2022.
//

import SwiftUI

struct RecipesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var recipes: FetchedResults<Recipe>
    @FocusState var focused: Bool
    @State var showNewRecipeView = false
    @State var newRecipeName = ""
    @State var showNewRecipeField = false
    @State var editMode = EditMode.inactive
    @State var selectedType: RecipeType?
    @State var selectedSpeed: Speed?
    @State var text = ""
    @State var onlyShowFavourites = false
    
    @Binding var selectedRecipe: Recipe?
    let picker: Bool
    
    var someFavourites: Bool {
        recipes.reduce(false) { $0 || $1.favourite }
    }
    var noActiveFilters: Bool {
        !onlyShowFavourites// && selectedType == nil && selectedSpeed == nil
    }
    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let favourite = onlyShowFavourites ? recipe.favourite : true
//            let type = recipe.type == selectedType?.rawValue ?? recipe.type
//            let speed = recipe.speed == selectedSpeed?.rawValue ?? recipe.speed
            let name = text.isEmpty || recipe.name?.localizedCaseInsensitiveContains(text) ?? false
            let ingredients = (recipe.ingredients?.allObjects as? [Ingredient] ?? []).reduce(false) { result, ingredient in
                result || ingredient.name?.localizedCaseInsensitiveContains(text) ?? false
            }
            return (ingredients || name) && favourite// && type && speed&& type && speed
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
                        RecipeRow(recipe: recipe, selectedRecipe: $selectedRecipe, editMode: editMode, picker: picker)
                    }
                    
                    if showNewRecipeField && !editMode.isEditing {
                        TextField("New Recipe", text: $newRecipeName)
                            .id(0)
                            .submitLabel(.done)
                            .focused($focused)
                            .onSubmit(submitNewRecipe)
                    }
                }
                .environment(\.editMode, .constant(picker ? .active : .inactive))
                .animation(.default, value: filteredRecipes)
                .navigationTitle("Recipes")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $text.animation(), placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Recipes, Ingredients")
                .overlay(alignment: .bottom) {
                    Text(filteredRecipes.count.formattedPlural(onlyShowFavourites ? "favourite" : "recipe") + ((noActiveFilters && text.isEmpty) ? "" : " found"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .animation(.none)
                        .padding(10)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack {
                            if !editMode.isEditing {
                                Button {
                                    withAnimation {
                                        showNewRecipeField = true
                                        list.scrollTo(0)
                                        focused = true
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                            if someFavourites {
                                Button {
                                    withAnimation {
                                        onlyShowFavourites.toggle()
                                    }
                                } label: {
                                    Image(systemName: onlyShowFavourites ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
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
                    ErrorLabel("Add a recipe", systemName: "doc.plaintext") {
                        showNewRecipeField = true
                        focused = true
                    }
                }
            }
        }
        .onAppear {
            showNewRecipeField = recipes.isNotEmpty
        }
        .onChange(of: selectedRecipe) { _ in
            dismiss()
        }
    }
    
    var filterMenu: some View {
        Menu {
            if someFavourites {
                Toggle(isOn: $onlyShowFavourites) {
                    Label("Filter Favourites", systemImage: "star")
                }
            }
            
            Picker("Recipe Type", selection: $selectedType) {
                Text("All Types")
                    .tag(nil as RecipeType?)
                ForEach(RecipeType.allCases, id: \.self) { type in
                    Text(type.name + "s")
                        .tag(type as RecipeType?)
                }
            }

            Picker("Recipe speed", selection: $selectedSpeed) {
                Text("All Speeds")
                    .tag(nil as Speed?)
                ForEach(Speed.sorted, id: \.self) { speed in
                    Text(speed.name)
                        .tag(speed as Speed?)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle" + (noActiveFilters ? "" : ".fill"))
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
