//
//  PrivacyView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct PrivacyView: View {
    @AppStorage("requireFaceID") private var requireFaceID = false
    @AppStorage("hideInAppSwitcher") private var hideInAppSwitcher = false
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $requireFaceID) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                        Text("Require Face ID / Touch ID")
                        Text("Protect sensitive health data")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Biometric Authentication")
                    Text("Requires authentication to open the app")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            Section {
                Toggle(isOn: $hideInAppSwitcher) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                        Text("Hide in App Switcher")
                        Text("Blur screenshot in multitasking view")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Switcher Privacy")
                    Text("Prevents others from seeing your data when scrolling through open apps")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}
