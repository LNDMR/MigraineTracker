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
            VStack(spacing: Theme.Spacing.large) {
                // Header Card - always shown
                VStack(spacing: Theme.Spacing.small) {
                    Text(event.loggedAt, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(event.loggedAt, style: .time)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.regular)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.medium)
                
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
