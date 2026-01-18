//
//  DurationView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct DurationView: View {
    @Binding var duration: MigraineEvent.Duration?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("How long did the symptoms last?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
            
            VStack(spacing: Theme.Spacing.regular) {
                HStack(spacing: Theme.Spacing.regular) {
                    DurationCard(
                        duration: .short,
                        isSelected: duration == .short
                    ) {
                        duration = .short
                    }
                    
                    DurationCard(
                        duration: .medium,
                        isSelected: duration == .medium
                    ) {
                        duration = .medium
                    }
                }
                
                HStack(spacing: Theme.Spacing.regular) {
                    DurationCard(
                        duration: .long,
                        isSelected: duration == .long
                    ) {
                        duration = .long
                    }
                    
                    DurationCard(
                        duration: .veryLong,
                        isSelected: duration == .veryLong
                    ) {
                        duration = .veryLong
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.extraLarge)
            
            Spacer()
        }
    }
}

struct DurationCard: View {
    let duration: MigraineEvent.Duration
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.medium) {
                Image(systemName: iconForDuration)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                
                Text(duration.label)
                    .font(.headline)
                    .foregroundColor(isSelected ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.extraLarge)
            .background(isSelected ? Theme.Colors.primaryAction : Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.large)
        }
    }
    
    private var iconForDuration: String {
        switch duration {
        case .short: return "clock"
        case .medium: return "clock.badge.checkmark"
        case .long: return "clock.arrow.circlepath"
        case .veryLong: return "hourglass"
        }
    }
}

#Preview {
    DurationView(duration: .constant(.medium))
}
