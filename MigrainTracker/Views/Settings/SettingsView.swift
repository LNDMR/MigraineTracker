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
                    Text("TRACKING")
                } footer: {
                    Text("Control how you log and track your migraines")
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
                    Text("DATA")
                } footer: {
                    Text("Manage your migraine data through export, backup, and deletion")
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
                    Text("PREFERENCES")
                } footer: {
                    Text("Configure app behavior, appearance, and security")
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
                    Text("INFO")
                } footer: {
                    Text("View statistics, get help, and learn more about the app")
                }
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
