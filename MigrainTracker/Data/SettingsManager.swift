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
            // First launch - empty selection
            self.settings = AppSettings()
        }
    }
    
    /// Get symptoms to display (user's selection only)
    var symptomsToDisplay: [String] {
        settings.selectedSymptoms
    }
    
    /// Get medications to display (user's selection only)
    var medicationsToDisplay: [String] {
        settings.selectedMedications
    }
    
    /// Check if user has set up symptoms
    var hasConfiguredSymptoms: Bool {
        !settings.selectedSymptoms.isEmpty
    }
    
    /// Check if user has set up medications
    var hasConfiguredMedications: Bool {
        !settings.selectedMedications.isEmpty
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
