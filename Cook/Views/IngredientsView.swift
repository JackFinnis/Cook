//
//  IngredientsView.swift
//  Cook
//
//  Created by Jack Finnis on 26/09/2022.
//

import SwiftUI

struct IngredientsView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var ingredients: FetchedResults<Ingredient>
    @FocusState var focused: Bool
    @State var newIngredientName = ""
    @State var editMode = EditMode.inactive
    @State var showNewIngredientField = false
    @State var onlyFavourites = false
    @State var text = ""
    
    @Binding var selection: Set<Ingredient>
    
    var someFavourites: Bool {
        ingredients.reduce(false) { $0 || $1.favourite }
    }
    var filteredIngredients: [Ingredient] {
        ingredients.filter { ingredient in
            let name = text.isEmpty || ingredient.name?.localizedCaseInsensitiveContains(text) ?? false
//            let favourite = onlyFavourites ? ingredient.favourite : true
            return name// && favourite
        }.sorted { one, two in
            one.recipes?.count ?? 0 > two.recipes?.count ?? 0
        }
    }
    
    var body: some View {
        ScrollViewReader { list in
            ZStack {
                List(selection: $selection) {
                    ForEach(filteredIngredients) { ingredient in
                        IngredientRow(ingredient: ingredient, selection: $selection, editMode: editMode)
                    }
                    
                    if showNewIngredientField && !editMode.isEditing {
                        TextField("New Ingredient", text: $newIngredientName)
                            .id(0)
                            .textInputAutocapitalization(.words)
                            .onSubmit(submitIngredient)
                            .focused($focused)
                            .submitLabel(.done)
                            .onChange(of: newIngredientName) { _ in
                                list.scrollTo(0)
                            }
                    }
                }
                .navigationTitle("Ingredients")
                .environment(\.editMode, .constant(.active))
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $text.animation(), placement: .navigationBarDrawer(displayMode: .always))
                .overlay(alignment: .bottom) {
                    Text(filteredIngredients.count.formattedPlural("ingredient") + ((onlyFavourites || text.isNotEmpty) ? " found" : ""))
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
                                        showNewIngredientField = true
                                        list.scrollTo(0)
                                        focused = true
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
//                            if someFavourites {
//                                Button {
//                                    withAnimation {
//                                        onlyFavourites.toggle()
//                                    }
//                                } label: {
//                                    Image(systemName: onlyFavourites ? "star.fill" : "star")
//                                        .foregroundColor(.yellow)
//                                }
//                            }
                            if ingredients.isNotEmpty {
                                EditButton(editMode: $editMode)
                            }
                        }
                        .animation(.none, value: editMode)
                    }
                }
                if ingredients.isEmpty && !focused && !showNewIngredientField {
                    ErrorLabel("Add ingredients", systemName: "fork.knife") {
                        showNewIngredientField = true
                        focused = true
                    }
                }
            }
        }
        .onAppear {
            showNewIngredientField = ingredients.isNotEmpty
            context.refreshAllObjects()
        }
    }
    
    func submitIngredient() {
        let name = newIngredientName.trimmingCharacters(in: .whitespaces)
        guard !ingredients.contains(where: { $0.name == name }),
              name.isNotEmpty
        else { newIngredientName = ""; return }
        
        let ingredient = Ingredient(context: context)
        ingredient.name = newIngredientName
        withAnimation {
            try? context.save()
            newIngredientName = ""
        }
        focused = true
    }
}
