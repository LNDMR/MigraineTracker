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
                NavigationLink(destination: SymptomPickerView(isSheet: false)) {
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
                VStack(alignment: .leading, spacing: 4) {
                    Text("Symptoms")
                    Text("Select which symptoms appear in your tracking forms")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            // MARK: - Medications
            Section {
                NavigationLink(destination: MedicationPickerView(isSheet: false)) {
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                            Text("Customize Medications")
                                .font(.body)
                            Text("\(settingsManager.settings.selectedMedications.count) medications selected")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                        Spacer()
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medications")
                    Text("Select which medications appear in your tracking forms")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            // MARK: - Quick Log Behavior
            Section {
                HStack(alignment: .center) {
                    Text("Track Details")
                        .font(.body)
                    
                    Spacer()
                    
                    Toggle("", isOn: $promptForDetails)
                        .labelsHidden()
                        .tint(Theme.Colors.primaryAction)
                }
                .frame(minHeight: 44)
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Log Behavior")
                    Text("Record more details after a Quick Log")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
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
