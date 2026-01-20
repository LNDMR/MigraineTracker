//
//  HistoryView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settings: SettingsManager
    @AppStorage("promptForDetails") private var promptForDetails = true
    
    @State private var selectedDate: Date?
    @State private var selectedEvent: MigraineEvent?
    @State private var showEventDetail = false
    @State private var showCreateConfirmation = false
    @State private var confirmationDate = Date()
    @State private var createdEventID: UUID?
    @State private var showDetailsFlow = false
    
    var body: some View {
        NavigationStack {
            CalendarView(
                selectedEvent: $selectedEvent,
                showEventDetail: $showEventDetail,
                onEmptyDayTapped: { date in
                    confirmationDate = date
                    showCreateConfirmation = true
                }
            )
            .navigationTitle("History")
            .navigationDestination(isPresented: $showEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(eventID: event.id)
                }
            }
            .sheet(isPresented: $showCreateConfirmation) {
                confirmationSheet
            }
            .fullScreenCover(isPresented: $showDetailsFlow) {
                if let eventID = createdEventID {
                    AddAttackDetailsFlow(eventID: eventID, store: store)
                        .environmentObject(store)
                        .environmentObject(settings)
                }
            }
        }
    }
    
    private var confirmationSheet: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()
            
            // Title
            Text("Log Migraine")
                .font(.title2)
                .fontWeight(.bold)
            
            // Show selected date with weekday (read-only)
            Text(confirmationDate.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .foregroundColor(Theme.Colors.secondaryText)
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.vertical, Theme.Spacing.medium)
                .background(Theme.Colors.secondaryBackground.opacity(0.5))
                .cornerRadius(Theme.CornerRadius.medium)
            
            // Subtitle
            Text("Add details or keep it simple")
                .font(.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: Theme.Spacing.medium) {
                // Add Details Button
                Button(action: { createEvent(openDetails: true) }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Add Details")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.large)
                    .background(Theme.Colors.primaryAction)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                
                // Save Button
                Button(action: { createEvent(openDetails: false) }) {
                    Text("Save")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.large)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                
                // Cancel
                Button(action: { showCreateConfirmation = false }) {
                    Text("Cancel")
                        .font(.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .padding(.vertical, Theme.Spacing.small)
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.large)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func createEvent(openDetails: Bool) {
        // Use noon as default time
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: confirmationDate)
        components.hour = 12
        components.minute = 0
        
        let finalDate = calendar.date(from: components) ?? confirmationDate
        
        // Create event
        let newEvent = MigraineEvent(loggedAt: finalDate)
        store.updateEvent(newEvent)
        createdEventID = newEvent.id
        
        // Close confirmation sheet
        showCreateConfirmation = false
        
        // Optionally open details flow
        if openDetails {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showDetailsFlow = true
            }
        }
    }
}
