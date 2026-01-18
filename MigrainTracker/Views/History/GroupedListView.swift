//
//  GroupedListView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct GroupedListView: View {
    @EnvironmentObject var store: MigraineStore
    
    private var groupedEvents: [(String, [MigraineEvent])] {
        let grouped = Dictionary(grouping: store.events) { event -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: event.loggedAt)
        }
        
        return grouped.map { (key, value) in
            (key, value.sorted { $0.loggedAt > $1.loggedAt })
        }
        .sorted { first, second in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            guard let date1 = formatter.date(from: first.0),
                  let date2 = formatter.date(from: second.0) else {
                return false
            }
            return date1 > date2
        }
    }
    
    var body: some View {
        List {
            if store.events.isEmpty {
                ContentUnavailableView(
                    "No Migraines Logged",
                    systemImage: "calendar",
                    description: Text("Your tracked migraines will appear here.")
                )
            } else {
                ForEach(groupedEvents, id: \.0) { month, events in
                    Section {
                        ForEach(events) { event in
                            NavigationLink {
                                EventDetailView(event: event)
                            } label: {
                                EventRow(event: event)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.deleteEvent(event)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text(month)
                            Spacer()
                            Text("\(events.count) attacks")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
