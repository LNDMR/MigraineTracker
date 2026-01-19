//
//  MigraineStore.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import Foundation
import Combine
import SwiftUI

/// Single source of truth for migraine events with persistent JSON storage
final class MigraineStore: ObservableObject {
    @Published private(set) var events: [MigraineEvent] = []
    
    private let fileURL: URL
    
    init() {
        // Store in app Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("migraine_events.json")
        
        loadEvents()
    }
    
    // MARK: - Quick Actions
    
    /// Creates and saves a new migraine event with current timestamp
    func quickLog() {
        let event = MigraineEvent(loggedAt: Date())
        events.insert(event, at: 0)
        saveEvents()
    }
    
    // MARK: - CRUD Operations
    
    /// Returns the most recent event, if any
    var latestEvent: MigraineEvent? {
        events.first
    }
    
    /// Find event by ID
    func event(withID id: UUID) -> MigraineEvent? {
        events.first { $0.id == id }
    }
    
    /// Update an existing event or insert a new one
    func updateEvent(_ updatedEvent: MigraineEvent) {
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            // Update existing event
            events[index] = updatedEvent
        } else {
            // Insert new event
            events.append(updatedEvent)
        }
        sortEvents()
        saveEvents()
    }
    
    /// Delete a specific event
    func deleteEvent(_ event: MigraineEvent) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    /// Delete events at specific offsets (for List swipe-to-delete)
    func deleteEvents(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
    }
    
    /// Clear all events
    func clearAllEvents() {
        events.removeAll()
        saveEvents()
    }
    
    /// Import events from backup (replaces current data)
    func importEvents(_ newEvents: [MigraineEvent]) {
        events = newEvents
        sortEvents()
        saveEvents()
    }
    
    /// Returns the most recent event from today that has no details added
    func todaysIncompleteEvent() -> MigraineEvent? {
        let calendar = Calendar.current
        let today = Date()
        
        return events.first { event in
            calendar.isDateInToday(event.loggedAt) && !event.hasDetails
        }
    }
    
    // MARK: - Analytics
    
    /// Count of events in the current month
    func eventsThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        return events.filter { event in
            calendar.isDate(event.loggedAt, equalTo: now, toGranularity: .month)
        }.count
    }

    // MARK: - Testing & Development

    #if DEBUG
    /// Populates the store with realistic sample migraine events for testing
    func addSampleEvents() {
        let calendar = Calendar.current
        let now = Date()
        
        var sampleEvents: [MigraineEvent] = []
        
        // Event 1: Today - incomplete (just quick logged)
        let today = now
        sampleEvents.append(MigraineEvent(loggedAt: today))
        
        // Event 2: Yesterday - complete with all details
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
            var event = MigraineEvent(loggedAt: yesterday)
            event.symptomsOnsetTime = .morning
            event.duration = .medium
            event.painLevel = .severe
            event.symptoms = ["Sensitivity to light", "Nausea", "Throbbing pain"]
            event.medication = "Ibuprofen 400mg"
            event.medicationHelped = true
            event.notes = "Started after waking up. Had to stay in dark room most of the day."
            sampleEvents.append(event)
        }
        
        // Event 3: 3 days ago - moderate
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) {
            var event = MigraineEvent(loggedAt: threeDaysAgo)
            event.symptomsOnsetTime = .afternoon
            event.duration = .short
            event.painLevel = .moderate
            event.symptoms = ["Throbbing pain", "Sensitivity to light"]
            event.medication = "Paracetamol"
            event.medicationHelped = false
            sampleEvents.append(event)
        }
        
        // Event 4: 5 days ago - mild
        if let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now) {
            var event = MigraineEvent(loggedAt: fiveDaysAgo)
            event.symptomsOnsetTime = .evening
            event.duration = .short
            event.painLevel = .mild
            event.symptoms = ["Mild headache"]
            sampleEvents.append(event)
        }
        
        // Event 5: 1 week ago - severe with lots of symptoms
        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
            var event = MigraineEvent(loggedAt: oneWeekAgo)
            event.symptomsOnsetTime = .night
            event.duration = .veryLong
            event.painLevel = .severe
            event.symptoms = ["Throbbing pain", "Nausea", "Sensitivity to light", "Sensitivity to sound", "Dizziness"]
            event.medication = "Sumatriptan 50mg"
            event.medicationHelped = true
            event.notes = "Worst migraine in months. Had to call in sick."
            sampleEvents.append(event)
        }
        
        // Event 6: 10 days ago - incomplete
        if let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now) {
            var event = MigraineEvent(loggedAt: tenDaysAgo)
            event.painLevel = .moderate
            sampleEvents.append(event)
        }
        
        // Event 7: 2 weeks ago
        if let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) {
            var event = MigraineEvent(loggedAt: twoWeeksAgo)
            event.symptomsOnsetTime = .morning
            event.duration = .long
            event.painLevel = .severe
            event.symptoms = ["Throbbing pain", "Visual disturbances", "Nausea"]
            event.medication = "Ibuprofen 600mg"
            event.medicationHelped = true
            sampleEvents.append(event)
        }
        
        // Event 8: 3 weeks ago
        if let threeWeeksAgo = calendar.date(byAdding: .day, value: -21, to: now) {
            var event = MigraineEvent(loggedAt: threeWeeksAgo)
            event.symptomsOnsetTime = .afternoon
            event.duration = .medium
            event.painLevel = .moderate
            event.symptoms = ["Throbbing pain", "Fatigue"]
            sampleEvents.append(event)
        }
        
        // Event 9: Last month - severe
        if let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) {
            var event = MigraineEvent(loggedAt: lastMonth)
            event.symptomsOnsetTime = .evening
            event.duration = .veryLong
            event.painLevel = .severe
            event.symptoms = ["Throbbing pain", "Nausea", "Sensitivity to light", "Vomiting"]
            event.medication = "Sumatriptan 100mg"
            event.medicationHelped = true
            event.notes = "Triggered by stress at work. Lasted through the night."
            sampleEvents.append(event)
        }
        
        // Event 10: 6 weeks ago
        if let sixWeeksAgo = calendar.date(byAdding: .day, value: -42, to: now) {
            var event = MigraineEvent(loggedAt: sixWeeksAgo)
            event.symptomsOnsetTime = .morning
            event.duration = .short
            event.painLevel = .mild
            event.symptoms = ["Mild headache", "Fatigue"]
            event.medication = "Paracetamol"
            event.medicationHelped = true
            sampleEvents.append(event)
        }
        
        // Event 11: 2 months ago - multiple events same day
        if let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now) {
            var event1 = MigraineEvent(loggedAt: twoMonthsAgo)
            event1.symptomsOnsetTime = .morning
            event1.duration = .medium
            event1.painLevel = .moderate
            event1.symptoms = ["Throbbing pain", "Sensitivity to light"]
            sampleEvents.append(event1)
            
            // Second event same day, different time
            if let sameDay = calendar.date(byAdding: .hour, value: 6, to: twoMonthsAgo) {
                var event2 = MigraineEvent(loggedAt: sameDay)
                event2.symptomsOnsetTime = .afternoon
                event2.duration = .short
                event2.painLevel = .mild
                event2.symptoms = ["Mild headache"]
                sampleEvents.append(event2)
            }
        }
        
        // Event 12: 2.5 months ago
        if let oldEvent = calendar.date(byAdding: .day, value: -75, to: now) {
            var event = MigraineEvent(loggedAt: oldEvent)
            event.symptomsOnsetTime = .night
            event.duration = .long
            event.painLevel = .severe
            event.symptoms = ["Throbbing pain", "Nausea", "Sensitivity to light"]
            event.medication = "Ibuprofen 400mg"
            event.medicationHelped = false
            sampleEvents.append(event)
        }
        
        // Add all sample events to store
        for event in sampleEvents {
            updateEvent(event)
        }
        
        print("✅ Added \(sampleEvents.count) sample migraine events")
    }

    /// Clear all events (useful for testing)
    func clearSampleEvents() {
        clearAllEvents()
        print("✅ Cleared all events")
    }
    #endif
    
    // MARK: - Medication History
    
    /// Returns a sorted list of all unique medications used (most recent first)
    var usedMedications: [String] {
        // Get all unique medications that have been used
        let medications = events
            .compactMap { $0.medication }
            .filter { !$0.isEmpty }
        
        // Use dictionary to track first occurrence (most recent)
        var seen: [String: Date] = [:]
        for event in events {
            if let med = event.medication, !med.isEmpty {
                if seen[med] == nil {
                    seen[med] = event.loggedAt
                }
            }
        }
        
        // Sort by most recently used
        return seen.sorted { $0.value > $1.value }.map { $0.key }
    }
    
    // MARK: - Persistence
    
    private func loadEvents() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // No file yet; start with empty array
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            events = try decoder.decode([MigraineEvent].self, from: data)
            sortEvents()
        } catch {
            print("❌ Failed to load events: \(error.localizedDescription)")
            // Keep empty array on error
        }
    }
    
    private func saveEvents() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(events)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to save events: \(error.localizedDescription)")
        }
    }
    
    /// Sort events newest-first
    private func sortEvents() {
        events.sort { $0.loggedAt > $1.loggedAt }
    }
}
