//
//  SettingsView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - TRACKING
                Section {
                    NavigationLink(destination: TrackingPreferencesView()) {
                        Label("Tracking Preferences", systemImage: "slider.horizontal.3")
                    }
                    
                    NavigationLink(destination: NotificationsView()) {
                        Label("Notifications", systemImage: "bell")
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TRACKING")
                        Text("Control how you log and track your migraines")
                            .font(.caption)
                            .textCase(.none)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                // MARK: - DATA
                Section {
                    NavigationLink(destination: ExportReportsView()) {
                        Label("Export & Reports", systemImage: "square.and.arrow.up")
                    }
                    
                    NavigationLink(destination: BackupView()) {
                        Label("Backup", systemImage: "arrow.clockwise.icloud")
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DATA")
                        Text("Manage your migraine data through export, backup, and deletion")
                            .font(.caption)
                            .textCase(.none)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                // MARK: - PREFERENCES
                Section {
                    NavigationLink(destination: AppearanceView()) {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                    
                    NavigationLink(destination: LanguageView()) {
                        Label("Language", systemImage: "globe")
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy", systemImage: "lock.shield")
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PREFERENCES")
                        Text("Configure app behavior, appearance, and security")
                            .font(.caption)
                            .textCase(.none)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                // MARK: - INFO
                Section {
                    NavigationLink(destination: StatisticsView()) {
                        HStack {
                            Label("Statistics", systemImage: "chart.bar")
                            Spacer()
                            Text("\(store.events.count)")
                                .foregroundColor(Theme.Colors.secondaryText)
                                .font(.subheadline)
                        }
                    }
                    
                    NavigationLink(destination: HelpSupportView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("INFO")
                        Text("View statistics, get help, and learn more about the app")
                            .font(.caption)
                            .textCase(.none)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
#if DEBUG
Section {
    Button("Add Sample Events") {
        store.addSampleEvents()
    }
    .foregroundColor(Theme.Colors.primaryAction)
    
    Button("Clear All Events") {
        store.clearSampleEvents()
    }
    .foregroundColor(Theme.Colors.error)
    
    Button("Reset Symptoms Setup") {
        settingsManager.settings.selectedSymptoms = []
        settingsManager.settings.customSymptoms = []
        settingsManager.save()
    }
    .foregroundColor(Theme.Colors.error)
    
    Button("Reset Medications Setup") {
        settingsManager.settings.selectedMedications = []
        settingsManager.settings.customMedications = []
        settingsManager.save()
    }
    .foregroundColor(Theme.Colors.error)
    
} header: {
    Text("Development Tools")
}
#endif
                
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MigraineStore())
        .environmentObject(SettingsManager())
}
