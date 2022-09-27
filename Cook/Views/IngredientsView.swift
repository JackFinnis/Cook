//
//  IngredientsView.swift
//  Cook
//
//  Created by Jack Finnis on 26/09/2022.
//

import SwiftUI

struct IngredientsView: View {
    @FetchRequest(sortDescriptors: []) var ingredients: FetchedResults<Ingredient>
    @Environment(\.managedObjectContext) var context
    @State var newIngredientName = ""
    @State var editMode = EditMode.inactive
    @State var selecting = EditMode.active
    @State var showNewIngredientField = false
    @FocusState var focused: Bool
    @State var text = ""
    
    @Binding var selection: Set<Ingredient>
    
    var filteredIngredients: [Ingredient] {
        ingredients.filter { ingredient in
            guard text.isNotEmpty else { return true }
            return ingredient.name?.localizedCaseInsensitiveContains(text) ?? false
        }.sorted { one, two in
            one.recipes?.count ?? 0 > two.recipes?.count ?? 0
        }
    }
    
    var body: some View {
        ScrollViewReader { list in
            ZStack {
                List(selection: $selection) {
                    ForEach(filteredIngredients) { ingredient in
                        Row {
                            Text(ingredient.name ?? "")
                                .tag(ingredient)
                        } trailing: {
                            DeleteButton(editMode: editMode) {
                                deleteIngredient(ingredient)
                            }
                            .buttonStyle(.borderless)
                        }
                        .tag(ingredient)
                    }
                    
                    if showNewIngredientField {
                        TextField("New Ingredient", text: $newIngredientName)
                            .id("New Ingredient")
                            .onSubmit(submitIngredient)
                            .focused($focused)
                            .submitLabel(.done)
                    }
                }
                .environment(\.editMode, $selecting)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle("Ingredients")
                .searchable(text: $text, placement: .navigationBarDrawer)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack {
                            if !editMode.isEditing {
                                Button {
                                    withAnimation {
                                        showNewIngredientField = true
                                        list.scrollTo("New Ingredient")
                                        focused = true
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
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
        .onChange(of: editMode) { editMode in
            withAnimation {
                selecting = editMode.isEditing ? .inactive : .active
            }
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
    
    func deleteIngredient(_ ingredient: Ingredient) {
        context.delete(ingredient)
        try? context.save()
    }
}
