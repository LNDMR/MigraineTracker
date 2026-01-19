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
    var selectedSymptoms: [String] = []  // Empty by default
    var customSymptoms: [String] = []
    var selectedMedications: [String] = []
    var customMedications: [String] = []
    
    /// Master list of default migraine symptoms
    static let defaultSymptoms = [
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
    
    /// Master list of common migraine medications
    static let defaultMedications = [
        "Ibuprofen",
        "Paracetamol",
        "Aspirin",
        "Sumatriptan",
        "Rizatriptan",
        "Zolmitriptan",
        "Eletriptan",
        "Naratriptan",
        "Almotriptan",
        "Frovatriptan",
        "Ergotamine",
        "Dihydroergotamine",
        "Acetaminophen with Caffeine",
        "Excedrin Migraine",
        "Naproxen",
        "Diclofenac",
        "Indomethacin",
        "Ketorolac",
        "Metoclopramide",
        "Prochlorperazine",
        "Promethazine",
        "Ondansetron",
        "Topiramate",
        "Propranolol",
        "Amitriptyline",
        "Valproate",
        "Botox (OnabotulinumtoxinA)",
        "Ubrelvy (Ubrogepant)",
        "Nurtec (Rimegepant)",
        "Aimovig (Erenumab)",
        "Emgality (Galcanezumab)",
        "Ajovy (Fremanezumab)"
    ].sorted()
    
    /// All available symptoms (default + custom)
    func allAvailableSymptoms() -> [String] {
        let combined = Set(Self.defaultSymptoms).union(Set(customSymptoms))
        return Array(combined).sorted()
    }
    
    /// All available medications (default + custom)
    func allAvailableMedications() -> [String] {
        let combined = Set(Self.defaultMedications).union(Set(customMedications))
        return Array(combined).sorted()
    }
}
