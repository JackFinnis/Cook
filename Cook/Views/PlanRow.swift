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
    let editMode: EditMode
    let justSuppers: Bool
    let empty: Bool
    let nextDayToPlan: Day?
    
    var recipe: Recipe? {
        switch meal {
        case .lunch:
            return day.lunch
        case .supper:
            return day.supper
        }
    }
    
    var leading: String {
        justSuppers ? day.date?.formattedApple() ?? "" : meal.rawValue
    }
    
    var body: some View {
        HStack {
            if editMode.isEditing {
                Row {
                    Text(leading)
                } trailing: {
                    if let recipe {
                        Text(recipe.name ?? "")
                            .foregroundColor(.secondary)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        DeleteButton(editMode: editMode) {
                            removeRecipe(recipe)
                        }
                    }
                }
            } else if let recipe {
                NavigationLink {
                    RecipeView(recipe: recipe)
                } label: {
                    Row {
                        Text(leading)
                    } trailing: {
                        Text(recipe.name ?? "")
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                NavigationLink {
                    RecipesView(selectedType: .meal, selectedRecipe: $selectedRecipe, picker: true)
                        .onChange(of: selectedRecipe, perform: didSelectRecipe)
                } label: {
                    Row {
                        Text(leading)
                    } trailing: {
                        if day == nextDayToPlan {
                            if meal == .lunch || justSuppers || !justSuppers && day.lunch != nil {
                                Text("Select a meal")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            if let recipe {
                Button("Remove") {
                    removeRecipe(recipe)
                }
                .tint(.red)
            }
        }
        .contextMenu {
            if let recipe {
                Button(role: .destructive) {
                    removeRecipe(recipe)
                } label: {
                    Label("Remove recipe", systemImage: "minus.circle")
                }
            }
        }
    }
    
    func didSelectRecipe(_ recipe: Recipe?) {
        selectedRecipe = nil
        guard let recipe else { return }
        switch meal {
        case .lunch:
            day.lunch = recipe
        case .supper:
            day.supper = recipe
        }
        try? context.save()
        Haptics.tap()
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
