//
//  TrackingPreferencesView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct TrackingPreferencesView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    @AppStorage("promptForDetails") private var promptForDetails = true
    
    var body: some View {
        Form {
            // MARK: - Symptoms
            Section {
                NavigationLink(destination: SymptomPickerView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                            Text("Customize Symptoms")
                                .font(.body)
                            Text("\(settingsManager.settings.selectedSymptoms.count) symptoms selected")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                        Spacer()
                    }
                }
            } header: {
                Text("Symptoms")
            } footer: {
                Text("Select which symptoms appear in your tracking forms. Only your selected symptoms will be shown when logging attacks.")
            }
            
            // MARK: - Medications
            Section {
                if store.usedMedications.isEmpty {
                    Text("No medications used yet")
                        .foregroundColor(Theme.Colors.secondaryText)
                        .font(.subheadline)
                } else {
                    ForEach(store.usedMedications, id: \.self) { medication in
                        HStack {
                            Image(systemName: "pills")
                                .foregroundColor(Theme.Colors.primaryAction)
                            Text(medication)
                        }
                    }
                }
            } header: {
                Text("Medications")
            } footer: {
                Text("Previously used medications will automatically appear as suggestions when tracking new attacks.")
            }
            
            // MARK: - Quick Log Behavior
            Section {
                Toggle(isOn: $promptForDetails) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                        Text("Prompt for Details")
                        Text("Show option to add details after quick log")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
            } header: {
                Text("Quick Log Behavior")
            } footer: {
                if promptForDetails {
                    Text("After quick logging, you'll be asked if you want to add details immediately or later.")
                } else {
                    Text("Quick log will save timestamp only, without prompting for details.")
                }
            }
        }
        .navigationTitle("Tracking Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TrackingPreferencesView()
            .environmentObject(MigraineStore())
            .environmentObject(SettingsManager())
    }
}
