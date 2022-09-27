//
//  ListRow.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct ListRow: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var ingredient: Ingredient
    @Binding var ingredients: Set<Ingredient>
    let list: ShoppingList?
    var inList: Bool { ingredients.contains(ingredient) }
    
    var body: some View {
        Row {
            if inList {
                Button {
                    removeIngredient(ingredient)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.title2)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            Text(ingredient.name ?? "")
        } trailing: {
            if inList {
                DeleteButton(editMode: .active) {
                    removeIngredient(ingredient)
                }
            } else {
                Button {
                    addIngredient(ingredient)
                } label: {
                    Image(systemName: "plus.circle")
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .font(.title2)
            }
        }
        .buttonStyle(.borderless)
        .swipeActions(edge: .leading) {
            if inList {
                Button("Got it") {
                    removeIngredient(ingredient)
                }
                .tint(.accentColor)
            }
        }
        .swipeActions(edge: .trailing) {
            if inList {
                Button("Remove", role: .destructive) {
                    removeIngredient(ingredient)
                }
            } else {
                Button("Add") {
                    addIngredient(ingredient)
                }
                .tint(.accentColor)
            }
        }
    }
    
    func addIngredient(_ ingredient: Ingredient) {
        withAnimation {
            ingredients.insert(ingredient)
            list?.addToIngredients(ingredient)
        }
        Task {
            try? context.save()
        }
    }
    
    func removeIngredient(_ ingredient: Ingredient) {
        withAnimation {
            ingredients.remove(ingredient)
            list?.removeFromIngredients(ingredient)
        }
        Task {
            try? context.save()
        }
    }
}
