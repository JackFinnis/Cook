//
//  InfoView.swift
//  Rivers
//
//  Created by Jack Finnis on 24/06/2022.
//

import SwiftUI
import StoreKit

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    @State var showShareSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {} header: {
                    VStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                            .cornerRadius(15)
                            .horizontallyCentred()
                        Text(NAME)
                            .font(.headline)
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Text("""
                        \(NAME) allows you to store all your favourite recipes in one place, plan your week's meals and manage your shopping list.

                        If the app has saved you time planning meals, please consider sharing it with your friends or leaving a review.
                        """)
                        .font(.subheadline)
                    }
                }
                .headerProminence(.increased)
                
                Section {
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    } label: {
                        Label("Rate \(NAME)", systemImage: "star")
                    }
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share \(NAME)", systemImage: "square.and.arrow.up")
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ShareView()
                    }
                    
                    Button {
                        var components = URLComponents(url: APP_URL, resolvingAgainstBaseURL: false)
                        components?.queryItems = [
                            URLQueryItem(name: "action", value: "write-review")
                        ]
                        if let url = components?.url {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Write a Review", systemImage: "quote.bubble")
                    }
                    
                    Button {
                        let url = URL(string: "mailto:" + EMAIL + "?subject=\(NAME.replacingOccurrences(of: " ", with: "%20"))%20Feedback")!
                        UIApplication.shared.open(url)
                    } label: {
                        Label("Send us Feedback", systemImage: "envelope")
                    }
                }
                
                Section {
                    Button {
                        let url = URL(string: "mailto:" + EMAIL + "?subject=\(NAME.replacingOccurrences(of: " ", with: "%20"))%20Support")!
                        UIApplication.shared.open(url)
                    } label: {
                        Label("\(NAME) Support", systemImage: "questionmark.circle")
                    }
                    Button {
                        UIApplication.shared.open(WEBSITE)
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .bold()
                    }
                }
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                InfoView()
            }
    }
}

struct ShareView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [APP_URL], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
