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
                    Text(ingredient.name ?? "")
                        .tag(ingredient)
                }
                .onDelete(perform: deleteIngredients)
                
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
                    Button {
                        list.scrollTo("New Ingredient")
                        focused = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
        try? context.save()
        newIngredientName = ""
        focused = true
    }
    
    func deleteIngredients(at offsets: IndexSet) {
        for index in offsets {
            let ingredient = filteredIngredients[index]
            context.delete(ingredient)
            try? context.save()
        }
    }
}
