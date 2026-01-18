//
//  AboutView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            Section {
                Link(destination: URL(string: "https://www.apple.com")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                Link(destination: URL(string: "https://www.apple.com")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
            
            Section {
                Link(destination: URL(string: "https://apps.apple.com")!) {
                    Label("Rate MigrainTracker", systemImage: "star")
                }
            }
            
            Section {
                VStack(alignment: .center, spacing: Theme.Spacing.tiny) {
                    Text("Made with care")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text("© 2026 Linda Kötter")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
