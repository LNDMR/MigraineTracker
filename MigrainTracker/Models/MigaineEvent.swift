//
//  MigaineEvent.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import Foundation
import SwiftUI

struct MigraineEvent: Identifiable, Codable, Equatable {

    var id: UUID = UUID()
    var loggedAt: Date
    
    var symptomsOnsetTime: TimeOfDay?
    var duration: Duration?
    var painLevel: PainLevel?
    var symptoms: [String]?
    var medications: [MedicationEntry] = []
    var notes: String?
    
    var hasDetails: Bool {
        return symptomsOnsetTime != nil ||
               duration != nil ||
               painLevel != nil ||
               symptoms != nil ||
               !medications.isEmpty ||
               notes != nil
    }
    
    // MARK: - Medication Entry
    
    struct MedicationEntry: Codable, Identifiable, Equatable {
        var id: UUID = UUID()
        var name: String
        var helped: Bool?
    }
    
    // MARK: - Pain Level
    
    enum PainLevel: Int, Codable, CaseIterable {
        case mild = 1
        case moderate = 2
        case severe = 3
        
        var label: String {
            switch self {
            case .mild: return "Mild"
            case .moderate: return "Moderate"
            case .severe: return "Severe"
            }
        }
        
        var description: String {
            switch self {
            case .mild: return "I can go about my day"
            case .moderate: return "I'm limited in what I can do"
            case .severe: return "I'm completely out of action"
            }
        }
        
        var color: Color {
            Theme.Colors.painLevel(self)
        }
    }
    
    // MARK: - Time of Day
    
    enum TimeOfDay: String, Codable, CaseIterable {
        case morning = "morning"
        case afternoon = "afternoon"
        case evening = "evening"
        case night = "night"
        
        var label: String {
            switch self {
            case .morning: return "Morning"
            case .afternoon: return "Afternoon"
            case .evening: return "Evening"
            case .night: return "Night"
            }
        }
        
        var timeRange: String {
            switch self {
            case .morning: return "6 AM - 12 PM"
            case .afternoon: return "12 PM - 6 PM"
            case .evening: return "6 PM - 10 PM"
            case .night: return "10 PM - 6 AM"
            }
        }
        
        var icon: String {
            switch self {
            case .morning: return "sun.min"
            case .afternoon: return "sun.max"
            case .evening: return "sun.horizon"
            case .night: return "moon.zzz"
            }
        }
    }
    
    // MARK: - Duration
    
    enum Duration: String, Codable, CaseIterable {
        case short = "1-4hrs"
        case medium = "4-6hrs"
        case long = "6-8hrs"
        case veryLong = "8+hrs"
        
        var label: String {
            switch self {
            case .short: return "1-4 hours"
            case .medium: return "4-6 hours"
            case .long: return "6-8 hours"
            case .veryLong: return "More than 8 hours"
            }
        }
    }
}
