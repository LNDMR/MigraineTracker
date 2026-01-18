//
//  HistoryView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: MigraineStore
    @AppStorage("historyViewMode") private var viewMode: String = "calendar"
    
    @State private var selectedDate: Date?
    @State private var showDateEvents = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewMode == "calendar" {
                    CalendarView(selectedDate: $selectedDate, showDateEvents: $showDateEvents)
                } else {
                    GroupedListView()
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            viewMode = viewMode == "calendar" ? "list" : "calendar"
                        }
                    } label: {
                        Image(systemName: viewMode == "calendar" ? "list.bullet" : "calendar")
                    }
                }
            }
            .sheet(isPresented: $showDateEvents) {
                if let date = selectedDate {
                    DateEventsSheet(date: date)
                }
            }
        }
    }
}
