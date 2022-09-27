//
//  ErrorLabel.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct ErrorLabel: View {
    let title: String
    let systemName: String
    let action: () -> Void
    
    init(_ title: String, systemName: String, action: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.action = action
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .font(.title)
                .foregroundColor(.secondary)
            Button(title) {
                withAnimation {
                    action()
                }
            }
            .font(.body)
            .buttonStyle(.borderedProminent)
        }
    }
}
