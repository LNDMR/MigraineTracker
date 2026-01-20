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
    @State private var editingTime = Date()
    @State private var showValidationError = false
    @State private var validationMessage = ""
    
    // Computed property that always gets fresh data from store
    private var event: MigraineEvent? {
        store.event(withID: eventID)
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
            if event != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if promptForDetails {
                            Button {
                                showEditFlow = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
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
        .sheet(isPresented: $showEditFlow) {
            NavigationStack {
                AddAttackDetailsFlow(eventID: eventID, store: store)
                    .environmentObject(store)
                    .environmentObject(SettingsManager())
            }
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
                    print("🗑️ Deleting event with ID: \(event.id)")
                    print("📊 Events before delete: \(store.events.count)")
                    store.deleteEvent(event)
                    print("📊 Events after delete: \(store.events.count)")
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
            VStack(spacing: Theme.Spacing.large) {
                // Header Card - Tappable to edit date/time
                Button(action: {
                    editingDate = event.loggedAt
                    editingTime = event.loggedAt
                    showDateEditor = true
                }) {
                    VStack(spacing: Theme.Spacing.small) {
                        HStack {
                                Text(event.loggedAt, style: .date)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.primaryAction.opacity(0.6))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.regular)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                .buttonStyle(.plain)
                
                // Show details only if promptForDetails is ON
                if promptForDetails {
                    if !event.hasDetails {
                        noDetailsPrompt
                    } else {
                        detailsSections(for: event)
                    }
                }
            }
            .padding(Theme.Spacing.regular)
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
        .presentationDetents([.medium])
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
    
    // MARK: - No Details Prompt
    
    private var noDetailsPrompt: some View {
        VStack(spacing: Theme.Spacing.large) {
            Text("No details logged yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Button {
                showEditFlow = true
            } label: {
                Text("Add Details")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.regular)
                    .background(Theme.Colors.primaryAction)
                    .foregroundColor(Theme.Colors.inverseText)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.horizontal, Theme.Spacing.huge)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.jumbo)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.large)
    }
    
    // MARK: - Details Sections
    
    @ViewBuilder
    private func detailsSections(for event: MigraineEvent) -> some View {
        // Pain Level
        if let painLevel = event.painLevel {
            DetailSection(title: "Pain Level", icon: "bolt.fill") {
                HStack {
                    Text(painLevel.label)
                        .font(.headline)
                    Spacer()
                    ForEach(1...3, id: \.self) { level in
                        Circle()
                            .fill(level <= painLevel.rawValue ? severityColor(for: painLevel) : Theme.Colors.secondaryBackground)
                            .frame(width: Theme.Size.indicator, height: Theme.Size.indicator)
                    }
                }
                
                Text(painLevel.description)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        }
        
        // Onset Time
        if let onset = event.symptomsOnsetTime {
            DetailSection(title: "Symptoms Began", icon: onset.icon) {
                HStack {
                    Text(onset.label)
                        .font(.headline)
                    Spacer()
                    Text(onset.timeRange)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        
        // Duration
        if let duration = event.duration {
            DetailSection(title: "Duration", icon: "clock.fill") {
                Text(duration.label)
                    .font(.headline)
            }
        }
        
        // Symptoms
        if let symptoms = event.symptoms, !symptoms.isEmpty {
            DetailSection(title: "Symptoms", icon: "list.bullet") {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    ForEach(symptoms, id: \.self) { symptom in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(Theme.Colors.primaryAction)
                            Text(symptom)
                        }
                    }
                }
            }
        }
        
        // Medication
        if let medication = event.medication {
            DetailSection(title: "Medication", icon: "cross.case.fill") {
                HStack {
                    Text(medication)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let helped = event.medicationHelped {
                        Label(helped ? "Helped" : "Didn't Help", systemImage: helped ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(helped ? Theme.Colors.success : Theme.Colors.error)
                    }
                }
            }
        }
        
        // Notes
        if let notes = event.notes, !notes.isEmpty {
            DetailSection(title: "Notes", icon: "note.text") {
                Text(notes)
                    .font(.body)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        }
    }
    
    private func severityColor(for level: MigraineEvent.PainLevel) -> Color {
        level.color
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.Colors.primaryAction)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .textCase(.uppercase)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.regular)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.medium)
    }
}
