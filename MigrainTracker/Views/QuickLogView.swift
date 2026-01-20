//
//  QuickLogView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import SwiftUI

struct QuickLogView: View {
    @EnvironmentObject var store: MigraineStore
    @AppStorage("promptForDetails") private var promptForDetails = true
    
    @State private var showDetailsFlow = false
    @State private var lastLoggedEventID: UUID?
    @State private var cardDismissed = false
    
    // Check for ANY event today
    private var todaysEvent: MigraineEvent? {
        let calendar = Calendar.current
        return store.events.first { event in
            calendar.isDateInToday(event.loggedAt)
        }
    }
    
    private var shouldShowCard: Bool {
        guard let event = todaysEvent else { return false }
        
        if promptForDetails {
            // Toggle ON: Only show if no details and not dismissed
            return !event.hasDetails && !cardDismissed
        } else {
            // Toggle OFF: Always show (for delete access)
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                if let event = todaysEvent, shouldShowCard {
                    // Event exists and should show card
                    LoggedMigraineCard(
                        event: event,
                        showDetailsButton: promptForDetails,
                        onDelete: {
                            withAnimation {
                                store.deleteEvent(event)
                                cardDismissed = false
                            }
                        },
                        onAddDetails: {
                            lastLoggedEventID = event.id
                            showDetailsFlow = true
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                    .id(event.id)
                } else {
                    // No event for today - show quick log button
                    QuickLogButton(onTap: handleQuickLog)
                }
                
                Spacer()
            }
            .navigationTitle("Quick Log")
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: todaysEvent?.id)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: shouldShowCard)
            .fullScreenCover(isPresented: $showDetailsFlow) {
                detailsFlowView
            }
            .onChange(of: store.events.count) { oldValue, newValue in
                // Reset card dismissed when event is deleted
                if newValue < oldValue {
                    cardDismissed = false
                }
            }
            .onChange(of: showDetailsFlow) { _, isShowing in
                if !isShowing {
                    // Reset card dismissed state after returning from details flow
                    cardDismissed = false
                }
            }
            .onChange(of: promptForDetails) { _, _ in
                // Reset state when toggle changes
                cardDismissed = false
            }
        }
    }
    
    private var detailsFlowView: some View {
        Group {
            if let eventID = lastLoggedEventID {
                AddAttackDetailsFlow(eventID: eventID, store: store)
                    .environmentObject(store)
                    .environmentObject(SettingsManager())
            }
        }
    }
    
    private func handleQuickLog() {
        let newEvent = MigraineEvent(loggedAt: Date())
        lastLoggedEventID = newEvent.id
        store.updateEvent(newEvent)
        cardDismissed = false
    }
}

// MARK: - Sub-Views

private struct QuickLogButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.jumbo) {
                // Organic blob visual with bolt
                ZStack {
                    NestedBlob(
                        outerSeed: 1,
                        innerSeed: 2,
                        outerSize: 160,
                        innerSize: 125,
                        innerOffset: CGSize(width: -8, height: -6),
                        outerColor: Theme.Colors.primaryAction.opacity(0.3),
                        innerColor: Theme.Colors.primaryAction.opacity(0.6)
                    )
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 160, height: 160)
                
                Text("Log Migraine")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.jumbo * 1.5)
        }
        .buttonStyle(.plain)
    }
}

private struct LoggedMigraineCard: View {
    let event: MigraineEvent
    let showDetailsButton: Bool
    let onDelete: () -> Void
    let onAddDetails: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            // Header with severe blob + checkmark
            VStack(spacing: Theme.Spacing.extraLarge) {
                // Multi-layer severe blob with checkmark
                ZStack {
                    // Base layer
                    NestedBlob(
                        outerSeed: 1,
                        innerSeed: 2,
                        outerSize: 110,
                        innerSize: 90,
                        innerOffset: CGSize(width: -6, height: -5),
                        outerColor: Theme.Colors.Raw.lavenderGrey.opacity(0.5),
                        innerColor: Theme.Colors.Raw.lavenderGrey.opacity(0.7)
                    )
                    
                    // Mid layer
                    NestedBlob(
                        outerSeed: 3,
                        innerSeed: 4,
                        outerSize: 85,
                        innerSize: 68,
                        innerOffset: CGSize(width: 4, height: 3),
                        outerColor: Theme.Colors.Raw.charcoal.opacity(0.4),
                        innerColor: Theme.Colors.Raw.charcoal.opacity(0.6)
                    )
                    .offset(x: -8, y: -6)
                    
                    // Top layer
                    NestedBlob(
                        outerSeed: 5,
                        innerSeed: 6,
                        outerSize: 65,
                        innerSize: 50,
                        innerOffset: CGSize(width: -3, height: 2),
                        outerColor: Theme.Colors.Raw.ironGrey.opacity(0.5),
                        innerColor: Theme.Colors.Raw.ironGrey.opacity(0.8)
                    )
                    .offset(x: 6, y: 4)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 110, height: 110)
                
                Text("Migraine logged for today")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            
            // Action buttons - always visible, Details conditionally shown
            HStack(spacing: Theme.Spacing.jumbo) {
                if showDetailsButton {
                    Button(action: onAddDetails) {
                        Text("Details")
                            .font(.body)
                            .foregroundColor(Theme.Colors.primaryAction)
                    }
                }
                
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .padding(Theme.Spacing.extraLarge)
    }
}

#Preview {
    QuickLogView()
        .environmentObject(MigraineStore())
}
