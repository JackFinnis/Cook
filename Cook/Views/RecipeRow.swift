//
//  RecipeRow.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct RecipeRow: View {
    @Environment(\.managedObjectContext) var context
    @State var showDeleteConfirmation = false
    
    @ObservedObject var recipe: Recipe
    @Binding var selectedRecipe: Recipe?
    let editMode: EditMode
    let picker: Bool
    
    var body: some View {
        Row {
            Text(recipe.name ?? "")
            if !editMode.isEditing && !picker {
                NavigationLink {
                    RecipeView(recipe: recipe)
                } label: {
                    Row {} trailing: {
                        if recipe.favourite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        } trailing: {
            if editMode.isEditing || picker {
                Button {
                    toggleFavourite()
                } label: {
                    Image(systemName: recipe.favourite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
                .padding(.trailing, editMode.isEditing ? 10 : 0)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            DeleteButton(editMode: editMode) {
                showDeleteConfirmation = true
            }
        }
        .buttonStyle(.borderless)
        .tag(recipe)
        .swipeActions {
            Button("Delete", role: .destructive) {
                showDeleteConfirmation = true
            }
        }
        .background {
            Color.clear.contextMenu {
                Button {
                    toggleFavourite()
                } label: {
                    Label(recipe.favourite ? "Unfavourite" : "Favourite", systemImage: recipe.favourite ? "star.slash" : "star")
                }
                if picker {
                    Button {
                        selectedRecipe = recipe
                    } label: {
                        Label("Select recipe", systemImage: "checkmark.circle")
                    }
                }
                Button(role: .destructive) {
                    deleteRecipe()
                } label: {
                    Label("Delete recipe", systemImage: "trash")
                }
            }
            .id(UUID())
        }
        .confirmationDialog("", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
            Button("Delete Recipe", role: .destructive, action: deleteRecipe)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    func toggleFavourite() {
        recipe.favourite.toggle()
        try? context.save()
    }
    
    func deleteRecipe() {
        context.delete(recipe)
        try? context.save()
        Haptics.success()
    }
}
