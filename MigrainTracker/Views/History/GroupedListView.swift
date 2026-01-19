//
//  GroupedListView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct GroupedListView: View {
    @EnvironmentObject var store: MigraineStore
    @State private var expandedMonths: Set<String> = []
    
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
        ScrollView {
            if store.events.isEmpty {
                ContentUnavailableView(
                    "No Migraines Logged",
                    systemImage: "calendar",
                    description: Text("Your tracked migraines will appear here.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    ForEach(groupedEvents, id: \.0) { month, events in
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            // Month header - tappable to expand/collapse
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if expandedMonths.contains(month) {
                                        expandedMonths.remove(month)
                                    } else {
                                        expandedMonths.insert(month)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(month)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.primaryAction)
                                        .rotationEffect(.degrees(expandedMonths.contains(month) ? 90 : 0))
                                    
                                    Spacer()
                                    
                                    Text("\(events.count) attacks")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.secondaryText)
                                }
                                .padding(.horizontal, Theme.Spacing.medium)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            // Events - only show if expanded
                            if expandedMonths.contains(month) {
                                ForEach(events) { event in
                                    NavigationLink {
                                        EventDetailView(event: event)
                                    } label: {
                                        EventRow(event: event)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.deleteEvent(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.medium)
            }
        }
        .onAppear {
            // Expand current month by default
            if let currentMonth = groupedEvents.first?.0 {
                expandedMonths.insert(currentMonth)
            }
        }
    }
}
