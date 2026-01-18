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
    
    /// Update an existing event
    func updateEvent(_ updatedEvent: MigraineEvent) {
        guard let index = events.firstIndex(where: { $0.id == updatedEvent.id }) else { return }
        events[index] = updatedEvent
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
    
    // MARK: - Analytics
    
    /// Count of events in the current month
    func eventsThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        return events.filter { event in
            calendar.isDate(event.loggedAt, equalTo: now, toGranularity: .month)
        }.count
    }
    
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
