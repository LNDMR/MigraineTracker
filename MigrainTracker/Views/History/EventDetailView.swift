//
//  EventDetailView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var store: MigraineStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("promptForDetails") private var promptForDetails = true
    
    let eventID: UUID
    
    @State private var showEditFlow = false
    @State private var showDeleteAlert = false
    @State private var showDateEditor = false
    @State private var editingDate = Date()
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    // Computed property that always gets fresh data from store
    private var event: MigraineEvent? {
        store.event(withID: eventID)
    }
    
    private var isToday: Bool {
        guard let event = event else { return false }
        return Calendar.current.isDateInToday(event.loggedAt)
    }
    
    var body: some View {
        Group {
            if let event = event {
                eventContent(event)
            } else {
                // Event was deleted
                ContentUnavailableView(
                    "Event Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This migraine event no longer exists")
                )
            }
        }
        .navigationTitle("Migraine Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if event != nil, promptForDetails {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditFlow = true
                        } label: {
                            Label("Edit Details", systemImage: "pencil")
                        }
                        
                        Button {
                            editingDate = event?.loggedAt ?? Date()
                            showDateEditor = true
                        } label: {
                            Label("Change Date", systemImage: "calendar")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showEditFlow) {
            AddAttackDetailsFlow(eventID: eventID, store: store)
                .environmentObject(store)
                .environmentObject(SettingsManager())
        }
        .sheet(isPresented: $showDateEditor) {
            dateEditorSheet
        }
        .alert("Cannot Change Date", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .alert("Delete Migraine Event?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let event = event {
                    store.deleteEvent(event)
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    private func eventContent(_ event: MigraineEvent) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                // Date Header - Display only, not tappable
                Text(event.loggedAt.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Show details only if promptForDetails is ON
                if promptForDetails {
                    if !event.hasDetails {
                        noDetailsPrompt
                    } else {
                        detailsContent(for: event)
                    }
                }
            }
            .padding(Theme.Spacing.large)
        }
    }
    
    // MARK: - No Details Prompt
    
    private var noDetailsPrompt: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            Text("No details logged yet")
                .font(.headline)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Button {
                showEditFlow = true
            } label: {
                Text("Add Details")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.large)
                    .background(Theme.Colors.primaryAction)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
        }
    }
    
    // MARK: - Details Content
    
    @ViewBuilder
    private func detailsContent(for event: MigraineEvent) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.extraLarge) {
            
            // Onset Time
            if let onset = event.symptomsOnsetTime {
                let preposition = onset == .night ? "at" : "in the"
                Text("Symptoms began \(preposition) \(onset.label.lowercased())")
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Divider()
            }
            
            // Duration
            if let duration = event.duration {
                Text("Attack lasted \(duration.label.lowercased())")
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Divider()
            }
            
            // Pain Level (context-aware tense)
            if let painLevel = event.painLevel {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Pain level \(isToday ? "is" : "was") \(painLevel.label.lowercased())")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text(painDescription(for: painLevel))
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Divider()
            }
            
            // Symptoms
            if let symptoms = event.symptoms, !symptoms.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    Text("Experienced")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        ForEach(symptoms, id: \.self) { symptom in
                            HStack(spacing: Theme.Spacing.small) {
                                Text("•")
                                    .foregroundColor(Theme.Colors.primaryAction)
                                Text(symptom)
                                    .font(.body)
                            }
                        }
                    }
                }
                
                Divider()
            }
            
            // Medication
            if let medication = event.medication {
                HStack {
                    Text("Took \(medication)")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    if let helped = event.medicationHelped {
                        Text(helped ? " - it helped" : " - it didn't help")
                            .font(.body)
                            .foregroundColor(helped ? Theme.Colors.success : Theme.Colors.error)
                    }
                }
                
                Divider()
            }
            
            // Notes
            if let notes = event.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    Text("Notes")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .textCase(.uppercase)
                    
                    Text(notes)
                        .font(.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .lineSpacing(4)
                }
            }
        }
    }
    
    // Convert pain description to past tense if not today
    private func painDescription(for level: MigraineEvent.PainLevel) -> String {
        if isToday {
            return level.description
        }
        
        // Convert to past tense
        switch level {
        case .mild:
            return "I was able to go about my day"
        case .moderate:
            return "I was limited in what I could do"
        case .severe:
            return "I was completely out of action"
        }
    }
    
    private var dateEditorSheet: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()
            
            Text("Change Date")
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Date Picker
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Theme.Colors.primaryAction)
                    .frame(width: 30)
                DatePicker("Date", selection: $editingDate, displayedComponents: .date)
                Spacer()
            }
            .padding()
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .padding(.horizontal, Theme.Spacing.large)
            
            Spacer()
            
            // Save Button
            Button(action: saveDateChange) {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.large)
                    .background(Theme.Colors.primaryAction)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.horizontal, Theme.Spacing.large)
            
            // Cancel Button
            Button(action: { showDateEditor = false }) {
                Text("Cancel")
                    .font(.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .padding(.vertical, Theme.Spacing.small)
            }
            .padding(.bottom, Theme.Spacing.large)
        }
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }
    
    private func saveDateChange() {
        guard var updatedEvent = event else { return }
        
        // Combine new date with original time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: editingDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: updatedEvent.loggedAt)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        let newDate = calendar.date(from: combined) ?? editingDate
        
        // Validate: Check if another event exists on this date (excluding current event)
        let conflictingEvent = store.events.first { otherEvent in
            otherEvent.id != eventID && calendar.isDate(otherEvent.loggedAt, inSameDayAs: newDate)
        }
        
        if let conflict = conflictingEvent {
            validationMessage = "A migraine is already logged for \(newDate.formatted(date: .long, time: .omitted)). Delete that event first if you want to move this one there."
            showValidationError = true
            return
        }
        
        // Update event with new date but keep original time
        updatedEvent.loggedAt = newDate
        store.updateEvent(updatedEvent)
        
        // Close sheet
        showDateEditor = false
    }
    
    private func severityColor(for level: MigraineEvent.PainLevel) -> Color {
        level.color
    }
}
