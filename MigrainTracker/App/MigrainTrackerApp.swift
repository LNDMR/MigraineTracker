//
//  MigrainTrackerApp.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import SwiftUI

@main
struct MigrainTrackerApp: App {
    @StateObject private var store = MigraineStore()
    @StateObject private var settingsManager = SettingsManager()
    @AppStorage("appTheme") private var appTheme: AppTheme = .auto
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .environmentObject(settingsManager)
                .preferredColorScheme(appTheme.colorScheme)
        }
    }
}
