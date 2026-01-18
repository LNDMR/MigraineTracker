//
//  CalendarView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: MigraineStore
    @Binding var selectedDate: Date?
    @Binding var showDateEvents: Bool
    
    @State private var currentMonth = Date()
    
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
                            selectedDate = date
                            showDateEvents = !eventsFor(date: date).isEmpty
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
            VStack(spacing: Theme.Spacing.tiny) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? (isToday ? Theme.Colors.primaryAction : Theme.Colors.primaryText) : Theme.Colors.secondaryText)
                
                // Event dots
                HStack(spacing: 2) {
                    ForEach(events.prefix(3)) { event in
                        Circle()
                            .fill(colorFor(painLevel: event.painLevel))
                            .frame(width: Theme.Size.dotTiny, height: Theme.Size.dotTiny)
                    }
                }
                .frame(height: Theme.Size.dotTiny)
            }
            .frame(maxWidth: .infinity, minHeight: Theme.Size.touchTarget)
            .background(isToday ? Theme.Colors.primaryAction.opacity(0.1) : Color.clear)
            .cornerRadius(Theme.CornerRadius.small)
        }
        .buttonStyle(.plain)
    }
    
    private func colorFor(painLevel: MigraineEvent.PainLevel?) -> Color {
        painLevel?.color ?? Theme.Colors.Raw.lavenderGrey.opacity(0.3)
    }
}
