//
//  String.swift
//  Cook
//
//  Created by Jack Finnis on 29/09/2022.
//

import Foundation

extension Int {
    func formattedPlural(_ singularWord: String) -> String {
        "\(self == 0 ? "No" : String(self)) \(singularWord)\(self == 1 ? "" : "s")"
    }
}
