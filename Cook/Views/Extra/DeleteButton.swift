//
//  DeleteButton.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct DeleteButton: View {
    let editMode: EditMode
    let action: () -> Void
    
    var body: some View {
        if editMode == .active {
            Button {
                withAnimation {
                    action()
                }
            } label: {
                Image(systemName: "minus.circle.fill")
            }
            .font(.title2)
            .foregroundColor(.red)
            .transition(.move(edge: .trailing).combined(with: .opacity))
            .buttonStyle(.borderless)
        }
    }
}
