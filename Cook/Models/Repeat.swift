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
                return "No Repeat"
            case 1:
                return "Every week"
            case 4:
                return "Every month"
            default:
                return "Every \(weeks) weeks"
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
