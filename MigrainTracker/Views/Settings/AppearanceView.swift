//
//  AppearanceView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct AppearanceView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .auto
    
    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $appTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Image(systemName: theme.icon)
                            Text(theme.label)
                        }
                        .tag(theme)
                    }
                }
                .pickerStyle(.inline)
            } header: {
                Text("Theme")
            } footer: {
                Text("Override system appearance for this app only. Useful for light sensitivity during migraines.")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - AppTheme Enum
enum AppTheme: String, CaseIterable, Codable {
    case light
    case dark
    case auto
    
    var label: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Auto (Follow System)"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max"
        case .dark: return "moon"
        case .auto: return "circle.lefthalf.filled"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceView()
    }
}
