//
//  OnsetView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct OnsetView: View {
    @Binding var timeOfDay: MigraineEvent.TimeOfDay?
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Spacing.jumbo) {
            Text("When did the symptoms begin?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
            
            VStack(spacing: Theme.Spacing.regular) {
                HStack(spacing: Theme.Spacing.regular) {
                    TimeOfDayCard(
                        timeOfDay: .morning,
                        isSelected: timeOfDay == .morning
                    ) {
                        timeOfDay = .morning
                    }
                    
                    TimeOfDayCard(
                        timeOfDay: .afternoon,
                        isSelected: timeOfDay == .afternoon
                    ) {
                        timeOfDay = .afternoon
                    }
                }
                
                HStack(spacing: Theme.Spacing.regular) {
                    TimeOfDayCard(
                        timeOfDay: .evening,
                        isSelected: timeOfDay == .evening
                    ) {
                        timeOfDay = .evening
                    }
                    
                    TimeOfDayCard(
                        timeOfDay: .night,
                        isSelected: timeOfDay == .night
                    ) {
                        timeOfDay = .night
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.extraLarge)
            
            Spacer()
        }
    }
}

struct TimeOfDayCard: View {
    let timeOfDay: MigraineEvent.TimeOfDay
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.medium) {
                Image(systemName: timeOfDay.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                
                Text(timeOfDay.label)
                    .font(.headline)
                    .foregroundColor(isSelected ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                
                Text(timeOfDay.timeRange)
                    .font(.caption)
                    .foregroundColor(isSelected ? Theme.Colors.inverseText.opacity(0.8) : Theme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.large)
            .background(isSelected ? Theme.Colors.primaryAction : Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.large)
        }
    }
}

#Preview {
    OnsetView(timeOfDay: .constant(.morning))
}
