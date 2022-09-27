//
//  PlanRow.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct PlanRow: View {
    @Environment(\.managedObjectContext) var context
    @State var selectedRecipe: Recipe?
    
    @ObservedObject var day: Day
    let meal: Meal
    let editing: Bool
    
    var recipe: Recipe? {
        switch meal {
        case .lunch:
            return day.lunch
        case .supper:
            return day.supper
        }
    }
    
    var body: some View {
        NavigationLink {
            if let recipe {
                RecipeView(recipe: recipe)
            } else {
                RecipesView(selectedRecipe: $selectedRecipe, picker: true)
            }
        } label: {
            Row {
                Text(meal.rawValue)
            } trailing: {
                if let recipe {
                    Text(recipe.name ?? "")
                    if editing {
                        Button {
                            removeRecipe(recipe)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .font(.title2)
                        .foregroundColor(.red)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
        }
        .swipeActions {
            if let recipe {
                Button("Remove") {
                    removeRecipe(recipe)
                }
                .tint(.red)
            }
        }
        .onChange(of: selectedRecipe, perform: didSelectRecipe)
        .buttonStyle(.borderless)
    }
    
    func didSelectRecipe(_ recipe: Recipe?) {
        guard let recipe else { return }
        switch meal {
        case .lunch:
            day.lunch = recipe
        case .supper:
            day.supper = recipe
        }
        try? context.save()
    }
    
    func removeRecipe(_ recipe: Recipe) {
        switch meal {
        case .lunch:
            recipe.removeFromLunches(day)
        case .supper:
            recipe.removeFromSuppers(day)
        }
        try? context.save()
    }
}
