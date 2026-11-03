//
//  CalendarView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: MigraineStore
    @AppStorage("promptForDetails") private var promptForDetails = true
    
    @Binding var selectedEvent: MigraineEvent?
    @Binding var showEventDetail: Bool
    
    @State private var currentMonth = Date()
    @State private var showDeleteAlert = false
    @State private var selectedEventForDelete: MigraineEvent?
    @State private var showCreateAlert = false
    @State private var selectedDateForCreate: Date?
    
    @State private var showConfirmationCard = false
    @State private var confirmedEvent: MigraineEvent?
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            VStack(spacing: Theme.Spacing.large) {
                MonthGridView(
                    currentMonth: $currentMonth,
                    hasEvent: { date in eventFor(date: date) != nil },
                    isSelected: { _ in false },
                    isDisabled: { _ in false },
                    onSelectDate: { date in handleDayTap(date: date) }
                )
                
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
                
                if showConfirmationCard, let event = confirmedEvent {
                    HStack {
                        Spacer()
                        confirmationCard(for: event)
                        Spacer()
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showConfirmationCard)
        .alert(selectedEventForDelete?.loggedAt.formatted(date: .complete, time: .omitted) ?? "", isPresented: $showDeleteAlert) {
            Button("Keep", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let event = selectedEventForDelete {
                    store.deleteEvent(event)
                }
            }
        } message: {
            Text("Delete this migraine?")
        }
        .alert(selectedDateForCreate?.formatted(date: .complete, time: .omitted) ?? "", isPresented: $showCreateAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Migraine") {
                if let date = selectedDateForCreate {
                    createEvent(for: date)
                }
            }
        } message: {
            Text("Log migraine for this day?")
        }
    }

    @ViewBuilder
    private func confirmationCard(for event: MigraineEvent) -> some View {
        VStack(spacing: Theme.Spacing.small) {
            Text("Migraine logged for \(event.loggedAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.subheadline)
                .foregroundColor(Theme.Colors.primaryText)
            
            Button {
                selectedEvent = event
                showEventDetail = true
                showConfirmationCard = false
            } label: {
                Text("Add Details")
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.primaryAction)
            }
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: 260)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 6)
    }
    
    private func handleDayTap(date: Date) {
        if let event = eventFor(date: date) {
            if promptForDetails {
                // Detail mode on — navigate to the full detail screen
                selectedEvent = event
                showEventDetail = true
            } else {
                // Detail mode off — no detail screen to show, so offer delete directly
                selectedEventForDelete = event
                showDeleteAlert = true
            }
        } else {
            selectedDateForCreate = date
            showCreateAlert = true
        }
    }
    
    private func eventFor(date: Date) -> MigraineEvent? {
        store.events.first { event in
            calendar.isDate(event.loggedAt, inSameDayAs: date)
        }
    }
    
    private var monthEventCount: Int {
        store.events.filter { event in
            calendar.isDate(event.loggedAt, equalTo: currentMonth, toGranularity: .month)
        }.count
    }
    
    private func createEvent(for date: Date) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        components.minute = 0
        
        let eventDate = calendar.date(from: components) ?? date
        let newEvent = MigraineEvent(loggedAt: eventDate)
        store.updateEvent(newEvent)
        
        if promptForDetails {
            confirmedEvent = newEvent
            showConfirmationCard = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if confirmedEvent?.id == newEvent.id {
                    showConfirmationCard = false
                }
            }
        }
    }
}

// MARK: - Month Grid (reusable)

struct MonthGridView: View {
    @Binding var currentMonth: Date
    let hasEvent: (Date) -> Bool
    let isSelected: (Date) -> Bool
    var isDisabled: (Date) -> Bool = { _ in false }
    let onSelectDate: (Date) -> Void
    var onWeekCountChange: ((Int) -> Void)? = nil
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: Theme.Spacing.small) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            hasEvent: hasEvent(date),
                            isSelected: isSelected(date),
                            isDisabled: isDisabled(date),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            onSelectDate(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: Theme.Size.touchTarget)
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear { reportWeekCount() }
        .onChange(of: currentMonth) { _ in reportWeekCount() }
    }
    
    private func reportWeekCount() {
        let weeks = Int(ceil(Double(daysInMonth.count) / 7.0))
        onWeekCountChange?(weeks)
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation { currentMonth = newMonth }
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation { currentMonth = newMonth }
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
        let leadingEmptyDays = (firstWeekday == 1 ? 6 : firstWeekday - 2)
        for _ in 0..<leadingEmptyDays { days.append(nil) }
        
        var date = monthInterval.start
        while date < monthInterval.end {
            days.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return days
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let hasEvent: Bool
    let isSelected: Bool
    var isDisabled: Bool = false
    let isToday: Bool
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Theme.Colors.primaryAction.opacity(0.15))
                        .frame(width: 32, height: 32)
                }
                
                if hasEvent {
                    Circle()
                        .stroke(Theme.Colors.primaryAction, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity, minHeight: Theme.Size.touchTarget)
            .background(isToday ? Theme.Colors.primaryAction.opacity(0.1) : Color.clear)
            .cornerRadius(Theme.CornerRadius.small)
            .opacity(isDisabled ? 0.4 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return Theme.Colors.secondaryText
        }
        return isToday ? Theme.Colors.primaryAction : Theme.Colors.primaryText
    }
}
