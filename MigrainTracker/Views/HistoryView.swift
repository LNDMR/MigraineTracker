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
    @AppStorage("historyViewMode") private var viewMode: String = "calendar"
    
    @State private var selectedDate: Date?
    @State private var selectedEvent: MigraineEvent?
    @State private var showEventDetail = false
    @State private var showDateEvents = false
    @State private var showAddPastEvent = false
    @State private var pastEventDate = Date()
    @State private var pastEventTime = Date()
    @State private var createdEventID: UUID?
    @State private var showDetailsFlow = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control for View Mode
                Picker("View Mode", selection: $viewMode) {
                    Label("Calendar", systemImage: "calendar")
                        .tag("calendar")
                    Label("List", systemImage: "list.bullet")
                        .tag("list")
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                Group {
                    if viewMode == "calendar" {
                        CalendarView(
                            selectedDate: $selectedDate,
                            selectedEvent: $selectedEvent,
                            showEventDetail: $showEventDetail,
                            showDateEvents: $showDateEvents
                        )
                    } else {
                        GroupedListView()
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(isPresented: $showEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(eventID: event.id)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPastEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.Colors.primaryAction)
                    }
                }
            }
            .sheet(isPresented: $showDateEvents) {
                if let date = selectedDate {
                    DateEventsSheet(date: date)
                }
            }
            .sheet(isPresented: $showAddPastEvent) {
                datePickerSheet
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
    
    private var datePickerSheet: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $pastEventDate, displayedComponents: .date)
                    DatePicker("Time", selection: $pastEventTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("When did the migraine occur?")
                }
                
                Section {
                    Button("Continue to Details") {
                        createPastEvent()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Theme.Colors.primaryAction)
                    .font(.headline)
                }
            }
            .navigationTitle("Add Past Migraine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddPastEvent = false
                    }
                }
            }
        }
    }
    
    private func createPastEvent() {
        // Combine date and time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: pastEventDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: pastEventTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        let finalDate = calendar.date(from: combined) ?? pastEventDate
        
        // Create event with past date
        let newEvent = MigraineEvent(loggedAt: finalDate)
        store.updateEvent(newEvent)
        createdEventID = newEvent.id
        
        // Close date picker and open details flow
        showAddPastEvent = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showDetailsFlow = true
        }
    }
}
