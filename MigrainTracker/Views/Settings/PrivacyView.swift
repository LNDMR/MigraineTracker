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
            } footer: {
                Text("When enabled, app requires biometric authentication to open")
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
            } footer: {
                Text("Prevents others from seeing your migraine data when scrolling through open apps")
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
