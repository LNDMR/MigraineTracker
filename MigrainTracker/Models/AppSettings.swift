//
//  AppSettings.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import Foundation

/// App-wide preferences and configuration
struct AppSettings: Codable {
    var name: String = ""
    var selectedSymptoms: [String] = []
    
    /// Master list of all possible migraine symptoms
    static let allSymptoms = [
        "Aura",
        "Nausea",
        "Vomiting",
        "Light Sensitivity",
        "Sound Sensitivity",
        "Smell Sensitivity",
        "Dizziness",
        "Vertigo",
        "Blurred Vision",
        "Vision Loss",
        "Seeing Spots",
        "Neck Pain",
        "Neck Stiffness",
        "Shoulder Pain",
        "Jaw Pain",
        "Throbbing Pain",
        "Pulsing Pain",
        "One-Sided Pain",
        "Forehead Pain",
        "Temple Pain",
        "Back of Head Pain",
        "Fatigue",
        "Confusion",
        "Difficulty Speaking",
        "Tingling",
        "Numbness",
        "Weakness",
        "Runny Nose",
        "Watery Eyes",
        "Facial Swelling",
        "Sweating",
        "Pale Skin",
        "Food Cravings",
        "Mood Changes",
        "Irritability",
        "Depression",
        "Anxiety",
        "Restlessness",
        "Difficulty Concentrating"
    ].sorted()
    
    /// Default symptoms for new users (common ones)
    static let defaultSymptoms = [
        "Aura",
        "Nausea",
        "Light Sensitivity",
        "Sound Sensitivity",
        "Dizziness",
        "Blurred Vision",
        "Neck Pain"
    ]
}
