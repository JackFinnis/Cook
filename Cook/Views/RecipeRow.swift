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
    let editMode: EditMode
    let picker: Bool
    
    var body: some View {
        Row {
            Text(recipe.name ?? "")
            if !editMode.isEditing && !picker {
                NavigationLink("") {
                    RecipeView(recipe: recipe)
                }
            }
        } trailing: {
            DeleteButton(editMode: editMode) {
                showDeleteConfirmation = true
            }
        }
        .tag(recipe)
        .swipeActions {
            Button("Delete", role: .destructive) {
                showDeleteConfirmation = true
            }
        }
        .confirmationDialog("", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
            Button("Delete Recipe", role: .destructive, action: deleteRecipe)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    func deleteRecipe() {
        context.delete(recipe)
        try? context.save()
        Haptics.success()
    }
}
