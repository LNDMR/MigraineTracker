//
//  HelpSupportView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        Form {
            Section("Getting Started") {
                Button(action: {
                    // TODO: Show onboarding
                }) {
                    Label("View Tutorial", systemImage: "play.circle")
                }
            }
            
            Section("Support") {
                Button(action: {
                    if let url = URL(string: "mailto:support@migraintracker.app") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Contact Support", systemImage: "envelope")
                }
                
                Button(action: {
                    if let url = URL(string: "mailto:support@migraintracker.app?subject=Bug%20Report") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Report a Bug", systemImage: "ladybug")
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelpSupportView()
    }
}
