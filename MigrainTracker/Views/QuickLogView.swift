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
    
    @State private var showConfirmation = false
    @State private var showDetailsFlow = false
    @State private var lastLoggedEventID: UUID?
    @State private var pendingEvent: MigraineEvent?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                if promptForDetails {
                    // Full mode - show pending card or button
                    if let pending = pendingEvent {
                        PendingEventCard(
                            event: pending,
                            onDelete: {
                                store.deleteEvent(pending)
                                pendingEvent = nil
                            },
                            onAddDetails: {
                                lastLoggedEventID = pending.id
                                showDetailsFlow = true
                            }
                        )
                    } else {
                        QuickLogButton(onTap: handleQuickLog)
                    }
                } else {
                    // Minimal mode - just button, no pending card
                    QuickLogButton(onTap: handleQuickLog)
                }
                
                Spacer()
            }
            .navigationTitle("Quick Log")
            .overlay {
                if showConfirmation {
                    if promptForDetails {
                        // Full confirmation with buttons
                        ConfirmationOverlay(
                            onDelete: handleDelete,
                            onAddDetails: {
                                showConfirmation = false
                                showDetailsFlow = true
                            }
                        )
                    } else {
                        // Minimal confirmation - just checkmark
                        MinimalConfirmation()
                    }
                }
            }
            .animation(.spring(), value: showConfirmation)
            .fullScreenCover(isPresented: $showDetailsFlow) {
                detailsFlowView
            }
            .onAppear {
                if promptForDetails {
                    checkForPendingEvent()
                }
            }
            .onChange(of: showDetailsFlow) { _, isShowing in
                if !isShowing && promptForDetails {
                    checkForPendingEvent()
                }
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
        
        if promptForDetails {
            pendingEvent = newEvent
        }
        
        showConfirmation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (promptForDetails ? 2.5 : 1.5)) {
            showConfirmation = false
        }
    }
    
    private func handleDelete() {
        if let pending = pendingEvent {
            store.deleteEvent(pending)
            pendingEvent = nil
        }
        showConfirmation = false
    }
    
    private func checkForPendingEvent() {
        pendingEvent = store.todaysIncompleteEvent()
    }
}

// MARK: - Sub-Views

private struct QuickLogButton: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.large) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primaryAction)
                
                Text("Log Migraine")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.jumbo * 1.5)
        }
        .buttonStyle(.plain)
    }
}

private struct PendingEventCard: View {
    let event: MigraineEvent
    let onDelete: () -> Void
    let onAddDetails: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.extraLarge) {
            // Simple header with time
            VStack(spacing: Theme.Spacing.small) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.primaryAction)
                
                Text(event.loggedAt.formatted(date: .omitted, time: .shortened))
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // Two big clean buttons
            VStack(spacing: Theme.Spacing.medium) {
                Button(action: onAddDetails) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                        Text("Add Details")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.large)
                    .background(Theme.Colors.primaryAction)
                    .foregroundColor(Theme.Colors.inverseText)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.title3)
                        Text("Delete")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.large)
                    .background(Theme.Colors.secondaryBackground)
                    .foregroundColor(Theme.Colors.primaryText)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
        }
        .padding(Theme.Spacing.extraLarge)
    }
}

private struct ConfirmationOverlay: View {
    let onDelete: () -> Void
    let onAddDetails: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.extraLarge) {
            // Big checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(Theme.Colors.success)
            
            // Two simple buttons
            VStack(spacing: Theme.Spacing.medium) {
                Button(action: onAddDetails) {
                    Text("Add Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.large)
                        .background(Theme.Colors.primaryAction)
                        .foregroundColor(Theme.Colors.inverseText)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                
                Button(action: onDelete) {
                    Text("Delete")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .padding(Theme.Spacing.extraLarge)
        .frame(maxWidth: 300)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.extraLarge)
        .shadow(color: Theme.Shadow.color, radius: Theme.Shadow.Radius.large)
    }
}

private struct MinimalConfirmation: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(Theme.Colors.success)
            
            Text("Saved")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding(Theme.Spacing.extraLarge)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.extraLarge)
        .shadow(color: Theme.Shadow.color, radius: Theme.Shadow.Radius.large)
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    QuickLogView()
        .environmentObject(MigraineStore())
}
