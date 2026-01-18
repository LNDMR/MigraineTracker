//
//  NotificationsView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("completeLogReminder") private var completeLogReminder: ReminderTime = .off
    @AppStorage("dailyCheckIn") private var dailyCheckIn = false
    @AppStorage("weeklySummary") private var weeklySummary: WeeklySummaryTime = .off
    
    var body: some View {
        Form {
            Section {
                Picker("Complete Log Reminder", selection: $completeLogReminder) {
                    ForEach(ReminderTime.allCases, id: \.self) { time in
                        Text(time.label).tag(time)
                    }
                }
            } header: {
                Text("Complete Log Reminder")
            } footer: {
                Text("Reminds you to add details after a quick log when you're feeling better")
            }
            
            Section {
                Toggle("Daily Check-In (8pm)", isOn: $dailyCheckIn)
            } footer: {
                Text("Evening prompt asking if you had a migraine today")
            }
            
            Section {
                Picker("Weekly Summary", selection: $weeklySummary) {
                    ForEach(WeeklySummaryTime.allCases, id: \.self) { time in
                        Text(time.label).tag(time)
                    }
                }
            } footer: {
                Text("Shows your weekly migraine count for pattern awareness")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ReminderTime Enum
enum ReminderTime: String, CaseIterable, Codable {
    case off
    case oneHour
    case threeHours
    case nextDay
    
    var label: String {
        switch self {
        case .off: return "Off"
        case .oneHour: return "1 hour later"
        case .threeHours: return "3 hours later"
        case .nextDay: return "Next day (9am)"
        }
    }
    
    var hours: Int? {
        switch self {
        case .off: return nil
        case .oneHour: return 1
        case .threeHours: return 3
        case .nextDay: return 24
        }
    }
}

// MARK: - WeeklySummaryTime Enum
enum WeeklySummaryTime: String, CaseIterable, Codable {
    case off
    case sundayEvening
    case mondayMorning
    
    var label: String {
        switch self {
        case .off: return "Off"
        case .sundayEvening: return "Sunday evening (8pm)"
        case .mondayMorning: return "Monday morning (9am)"
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
