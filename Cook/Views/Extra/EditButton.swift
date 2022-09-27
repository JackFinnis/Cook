//
//  EditButton.swift
//  Cook
//
//  Created by Jack Finnis on 27/09/2022.
//

import SwiftUI

struct EditButton: View {
    @Binding var editMode: EditMode
    var editing: Bool { editMode == .active }
    
    var body: some View {
        Button(editing ? "Done" : "Edit") {
            withAnimation {
                editMode = editing ? .inactive : .active
            }
        }
        .font(.body.weight(editing ? .semibold : .regular))
        .animation(.none, value: editing)
    }
}
