//
//  WelcomeView.swift
//  Location
//
//  Created by Jack Finnis on 27/07/2022.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .cornerRadius(15)
                .horizontallyCentred()
                .padding()
            Text("Welcome to\n\(NAME)")
                .font(.largeTitle.bold())
                .horizontallyCentred()
                .padding(.bottom)
                .multilineTextAlignment(.center)
            
            WelcomeRow("Store your favourite recipes", systemName: "book", description: "Keep track of all your recipes and search them by type, speed and ingredients.")
            WelcomeRow("Plan your week's meals", systemName: "calendar", description: "Make a meal plan each week and never worry about missing a meal again.")
            WelcomeRow("Manage your shopping list", systemName: "list.bullet", description: "Receive smart suggestions of ingredients you'll need each week.")
            
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Get Started")
                    .bold()
                    .padding()
                    .horizontallyCentred()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(14)
            }
        }
        .padding()
    }
}

struct WelcomeRow: View {
    let title: String
    let systemName: String
    let description: String
    
    init(_ title: String, systemName: String, description: String) {
        self.title = title
        self.systemName = systemName
        self.description = description
    }
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                WelcomeView()
            }
    }
}
