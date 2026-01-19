//
//  EventRow.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct EventRow: View {
    @AppStorage("promptForDetails") private var promptForDetails = true
    let event: MigraineEvent
    
    var body: some View {
        if promptForDetails {
            // Full mode - show details
            detailedRow
        } else {
            // Minimal mode - just date
            minimalRow
        }
    }
    
    private var detailedRow: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            // Header: Date and time of day
            HStack(spacing: Theme.Spacing.small) {
                Text(event.loggedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                
                if let onset = event.symptomsOnsetTime {
                    Text(onset.label.lowercased())
                        .font(.headline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
            }
            
            // Severity badge (only if logged)
            if let severity = event.painLevel {
                HStack(spacing: Theme.Spacing.small) {
                    Circle()
                        .fill(severity.color)
                        .frame(width: 12, height: 12)
                    
                    Text(severity.label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.vertical, Theme.Spacing.small)
                .background(severity.color.opacity(0.15))
                .cornerRadius(Theme.CornerRadius.medium)
            }
            
            // Symptoms preview (only if logged)
            if let symptoms = event.symptoms, !symptoms.isEmpty {
                HStack(spacing: Theme.Spacing.small) {
                    Image(systemName: "list.bullet.circle")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text(symptoms.first ?? "")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .lineLimit(1)
                }
            }
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.large)
    }
    
    private var minimalRow: some View {
        HStack {
            Text(event.loggedAt.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            
            Spacer()
        }
        .padding(Theme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.large)
    }
}
