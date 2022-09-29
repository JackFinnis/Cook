//
//  IngredientRow.swift
//  Cook
//
//  Created by Jack Finnis on 29/09/2022.
//

import SwiftUI

struct IngredientRow: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var ingredient: Ingredient
    @Binding var selection: Set<Ingredient>
    let editMode: EditMode
    
    var selected: Bool { selection.contains(ingredient) }
    
    var body: some View {
        Row {
            Text(ingredient.name ?? "")
                .tag(ingredient)
        } trailing: {
            if editMode.isEditing || ingredient.favourite {
                Image(systemName: ingredient.favourite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .padding(.trailing, editMode.isEditing ? 10 : 0)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .onTapGesture {
                        if editMode.isEditing {
                            toggleFavourite()
                        }
                    }
            }
            DeleteButton(editMode: editMode) {
                deleteIngredient()
            }
        }
        .buttonStyle(.borderless)
        .tag(ingredient)
        .background {
            Color.clear.contextMenu {
                Button {
                    toggleFavourite()
                } label: {
                    Label(ingredient.favourite ? "Unfavourite" : "Favourite", systemImage: ingredient.favourite ? "star.slash" : "star")
                }
                Button(role: selected ? .destructive : .none) {
                    toggleSelection()
                } label: {
                    Label(selected ? "Remove ingredient" : "Add ingredient", systemImage: selected ? "minus.circle" : "checkmark.circle")
                }
                Button(role: .destructive) {
                    deleteIngredient()
                } label: {
                    Label("Delete Ingredient", systemImage: "trash")
                }
            }
            .id(UUID())
        }
    }
    
    func toggleSelection() {
        if selection.contains(ingredient) {
            selection.remove(ingredient)
        } else {
            selection.insert(ingredient)
        }
    }
    
    func toggleFavourite() {
        ingredient.favourite.toggle()
        try? context.save()
    }
    
    func deleteIngredient() {
        context.delete(ingredient)
        try? context.save()
    }
}
