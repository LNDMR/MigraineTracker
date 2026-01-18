//
//  MainTabView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import SwiftUI

struct MainTabView: View {
    init() {
        // Tab Bar Appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        
        let lavenderGrey = UIColor(Theme.Colors.secondaryText)
        tabAppearance.stackedLayoutAppearance.normal.iconColor = lavenderGrey
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: lavenderGrey
        ]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // Navigation Bar Appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        
        // Large titles (big headlines)
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Theme.Colors.primaryText) // IronGrey
        ]
        
        // Regular/inline titles (smaller headlines)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.Colors.primaryText) // IronGrey
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
    
    var body: some View {
        TabView {
            QuickLogView()
                .tabItem {
                    Label("Log", systemImage: "bolt.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MigraineStore())
}
