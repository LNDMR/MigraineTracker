//
//  StatisticsView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: MigraineStore
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Total Attacks")
                    Spacer()
                    Text("\(store.events.count)")
                        .foregroundColor(Theme.Colors.secondaryText)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("This Month")
                    Spacer()
                    Text("\(store.eventsThisMonth())")
                        .foregroundColor(Theme.Colors.secondaryText)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Last Month")
                    Spacer()
                    Text("\(lastMonthCount())")
                        .foregroundColor(Theme.Colors.secondaryText)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            } header: {
                Text("Summary")
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func lastMonthCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return 0 }
        
        return store.events.filter { event in
            calendar.isDate(event.loggedAt, equalTo: lastMonth, toGranularity: .month)
        }.count
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
            .environmentObject(MigraineStore())
    }
}
