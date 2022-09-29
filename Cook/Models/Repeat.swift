//
//  Repeat.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import Foundation

enum Repeat: Hashable {
    case weeks(weeks: Int)
    
    init(weeks: Int) {
        self = .weeks(weeks: weeks)
    }
    
    var weeks: Int {
        switch self {
        case .weeks(let weeks):
            return weeks
        }
    }
    
    var name: String {
        switch self {
        case .weeks(let weeks):
            switch weeks {
            case 0:
                return "Don't repeat meal plan"
            case 1:
                return "Repeat every week"
            case 4:
                return "Repeat every month"
            default:
                return "Repeat every \(weeks) weeks"
            }
        }
    }
    
    var interval: TimeInterval {
        switch self {
        case .weeks(let weeks):
            return Double(weeks)*7*24*3600
        }
    }
}
