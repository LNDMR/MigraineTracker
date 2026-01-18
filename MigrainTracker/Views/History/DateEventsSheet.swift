//
//  DateEventsSheet.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct DateEventsSheet: View {
    @EnvironmentObject var store: MigraineStore
    @Environment(\.dismiss) private var dismiss
    
    let date: Date
    
    private var events: [MigraineEvent] {
        store.events.filter { event in
            Calendar.current.isDate(event.loggedAt, inSameDayAs: date)
        }
        .sorted { $0.loggedAt < $1.loggedAt }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(events) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventRow(event: event)
                    }
                }
            }
            .navigationTitle(formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
