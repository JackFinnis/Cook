//
//  Speed.swift
//  Cook
//
//  Created by Jack Finnis on 29/09/2022.
//

import Foundation

enum Speed: Int16, CaseIterable {
    static let sorted: [Speed] = [.fast, .medium, .slow]
    
    case medium
    case slow
    case fast
    
    var name: String {
        switch self {
        case .medium:
            return "Medium"
        case .slow:
            return "Slow"
        case .fast:
            return "Quick"
        }
    }
}
