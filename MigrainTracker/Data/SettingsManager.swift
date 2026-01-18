//
//  SettingsManager.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import Foundation
import Combine

/// Manages app-wide settings and preferences
final class SettingsManager: ObservableObject {
    @Published var settings: AppSettings
    
    private let fileURL: URL
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("app_settings.json")
        
        // Load settings
        if let loadedSettings = Self.load(from: fileURL) {
            self.settings = loadedSettings
        } else {
            // First launch - use defaults
            self.settings = AppSettings(selectedSymptoms: AppSettings.defaultSymptoms)
        }
    }
    
    /// Get symptoms to display (user's selection, or defaults if none)
    var symptomsToDisplay: [String] {
        settings.selectedSymptoms.isEmpty
            ? AppSettings.defaultSymptoms
            : settings.selectedSymptoms
    }
    
    /// Save settings to disk
    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(settings)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to save settings: \(error.localizedDescription)")
        }
    }
    
    /// Load settings from disk
    private static func load(from url: URL) -> AppSettings? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(AppSettings.self, from: data)
        } catch {
            print("❌ Failed to load settings: \(error.localizedDescription)")
            return nil
        }
    }
}
