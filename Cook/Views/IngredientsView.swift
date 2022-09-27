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
                
                TextField("Ingredient", text: $newIngredientName)
                    .id("New Ingredient")
                    .onSubmit(submitIngredient)
                    .focused($focused)
                    .submitLabel(.done)
            }
            .environment(\.editMode, .constant(.active))
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Ingredients")
            .searchable(text: $text)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        if !editMode.isEditing {
                            Button {
                                list.scrollTo("New Ingredient")
                                focused = true
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
        }
    }
    
    func submitIngredient() {
        guard !ingredients.contains(where: { $0.name == newIngredientName }),
              newIngredientName.isNotEmpty
        else { return }
        
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
