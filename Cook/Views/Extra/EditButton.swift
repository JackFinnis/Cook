//
//  EditButton.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct EditButton: View {
    @Binding var editMode: EditMode
    
    var body: some View {
        Button(editMode.isEditing ? "Done" : "Edit") {
            withAnimation {
                editMode = editMode.isEditing ? .inactive : .active
            }
        }
        .font(.body.weight(editMode.isEditing ? .semibold : .regular))
        .animation(.none, value: editMode.isEditing)
        .onDisappear {
            withAnimation {
                editMode = .inactive
            }
        }
    }
}
