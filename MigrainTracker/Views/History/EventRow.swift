//
//  EventRow.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct EventRow: View {
    let event: MigraineEvent
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Severity indicator
            Circle()
                .fill(severityColor)
                .frame(width: Theme.Size.indicator, height: Theme.Size.indicator)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                HStack {
                    Text(event.loggedAt, style: .date)
                        .font(.headline)
                    
                    if let onset = event.symptomsOnsetTime {
                        Image(systemName: onset.icon)
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                        Text(onset.label)
                            .font(.caption)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                HStack {
                    Text(event.loggedAt, style: .time)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    if let duration = event.duration {
                        Text("•")
                            .foregroundColor(Theme.Colors.secondaryText)
                        Text(duration.label)
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .padding(.vertical, Theme.Spacing.tiny)
    }
    
    private var severityColor: Color {
        event.painLevel?.color ?? Theme.Colors.Raw.lavenderGrey.opacity(0.3)
    }
}
