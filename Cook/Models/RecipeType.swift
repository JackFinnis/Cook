//
//  RecipeType.swift
//  Cook
//
//  Created by Jack Finnis on 29/09/2022.
//

import Foundation

enum RecipeType: Int16, CaseIterable {
    case meal
    case treat
    
    var name: String {
        switch self {
        case .meal:
            return "Meal"
        case .treat:
            return "Treat"
        }
    }
}
