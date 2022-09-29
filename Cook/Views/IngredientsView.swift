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
    @FocusState var focused: Bool
    @State var newIngredientName = ""
    @State var editMode = EditMode.inactive
    @State var selecting = EditMode.active
    @State var showNewIngredientField = false
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
                    
                    if showNewIngredientField && !editMode.isEditing {
                        TextField("New Ingredient", text: $newIngredientName)
                            .id(0)
                            .onSubmit(submitIngredient)
                            .focused($focused)
                            .submitLabel(.done)
                            .onChange(of: newIngredientName) { _ in
                                withAnimation {
                                    list.scrollTo(0)
                                }
                            }
                    }
                }
                .environment(\.editMode, $selecting)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $text, placement: .navigationBarDrawer(displayMode: .always))
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
