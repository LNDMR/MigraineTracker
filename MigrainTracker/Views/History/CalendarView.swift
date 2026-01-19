//
//  CalendarView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settings: SettingsManager
    @Binding var selectedDate: Date?
    @Binding var selectedEvent: MigraineEvent?
    @Binding var showEventDetail: Bool
    @Binding var showDateEvents: Bool
    
    @State private var currentMonth = Date()
    @State private var createdEventID: UUID?
    @State private var showDetailsFlow = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.primaryAction)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.primaryAction)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Days of Week Header
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: Theme.Spacing.small) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            events: eventsFor(date: date),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            handleDayTap(date: date)
                        }
                    } else {
                        Color.clear
                            .frame(height: Theme.Size.touchTarget)
                    }
                }
            }
            .padding(.horizontal)
            
            // Monthly Summary
            VStack(spacing: Theme.Spacing.small) {
                Divider()
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(Theme.Colors.primaryAction)
                    Text("\(monthEventCount) attacks this month")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .padding(.bottom)
            }
            
            Spacer()
        }
        .fullScreenCover(isPresented: $showDetailsFlow) {
            if let eventID = createdEventID {
                AddAttackDetailsFlow(eventID: eventID, store: store)
                    .environmentObject(store)
                    .environmentObject(settings)
            }
        }
    }
    
    // MARK: - Day Tap Handler
    
    private func handleDayTap(date: Date) {
        let events = eventsFor(date: date)
        
        if events.isEmpty {
            // No events on this day - create new event with this date and open details flow
            createEventForDate(date)
        } else if events.count == 1 {
            // Single event - go directly to detail view
            selectedEvent = events.first
            showEventDetail = true
        } else {
            // Multiple events - show list sheet to choose
            selectedDate = date
            showDateEvents = true
        }
    }
    
    private func createEventForDate(_ date: Date) {
        // Create event with selected date (keep the time as-is or set to noon)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12  // Default to noon
        components.minute = 0
        
        let eventDate = calendar.date(from: components) ?? date
        
        let newEvent = MigraineEvent(loggedAt: eventDate)
        store.updateEvent(newEvent)
        createdEventID = newEvent.id
        showDetailsFlow = true
    }
    
    // MARK: - Helper Functions
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        var days: [Date?] = []
        
        // Add leading empty cells (Monday = 2 in weekday, we want 0-based where Monday = 0)
        let leadingEmptyDays = (firstWeekday == 1 ? 6 : firstWeekday - 2)
        for _ in 0..<leadingEmptyDays {
            days.append(nil)
        }
        
        // Add all days in month
        var date = monthInterval.start
        while date < monthInterval.end {
            days.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return days
    }
    
    private func eventsFor(date: Date) -> [MigraineEvent] {
        store.events.filter { event in
            calendar.isDate(event.loggedAt, inSameDayAs: date)
        }
    }
    
    private var monthEventCount: Int {
        store.events.filter { event in
            calendar.isDate(event.loggedAt, equalTo: currentMonth, toGranularity: .month)
        }.count
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let events: [MigraineEvent]
    let isToday: Bool
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Circle around date if has events
                if !events.isEmpty {
                    Circle()
                        .stroke(Theme.Colors.primaryAction, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? (isToday ? Theme.Colors.primaryAction : Theme.Colors.primaryText) : Theme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: Theme.Size.touchTarget)
            .background(isToday ? Theme.Colors.primaryAction.opacity(0.1) : Color.clear)
            .cornerRadius(Theme.CornerRadius.small)
        }
        .buttonStyle(.plain)
    }
}
