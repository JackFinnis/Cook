//
//  Collection.swift
//  Paddle
//
//  Created by Jack Finnis on 11/09/2022.
//

import Foundation

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
    
    func formattedPlural(_ singularWord: String) -> String {
        "\(count == 0 ? "No" : String(count)) \(singularWord)\(count == 1 ? "" : "s")"
    }
}
