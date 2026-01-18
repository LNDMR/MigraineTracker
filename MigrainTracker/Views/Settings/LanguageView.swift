//
//  LanguageView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct LanguageView: View {
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .auto
    
    var body: some View {
        Form {
            Section {
                Picker("App Language", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        HStack {
                            Text(language.flag)
                            Text(language.label)
                        }
                        .tag(language)
                    }
                }
                .pickerStyle(.inline)
            } footer: {
                Text("Override your phone's system language for this app only. Auto mode follows your iPhone's language setting.")
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - AppLanguage Enum
enum AppLanguage: String, CaseIterable, Codable {
    case auto
    case english
    case german
    
    var label: String {
        switch self {
        case .auto: return "Auto (Follow System)"
        case .english: return "English"
        case .german: return "Deutsch"
        }
    }
    
    var flag: String {
        switch self {
        case .auto: return "🌐"
        case .english: return "🇬🇧"
        case .german: return "🇩🇪"
        }
    }
    
    var code: String? {
        switch self {
        case .auto: return nil
        case .english: return "en"
        case .german: return "de"
        }
    }
}

#Preview {
    NavigationStack {
        LanguageView()
    }
}
