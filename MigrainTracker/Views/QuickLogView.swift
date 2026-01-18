//
//  QuickLogView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import SwiftUI

struct QuickLogView: View {
    @EnvironmentObject var store: MigraineStore
    @State private var showConfirmation = false
    @State private var showDetailsFlow = false
    @State private var lastLoggedEventID: UUID?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Big Quick Log Button
                Button(action: {
                    let newEvent = MigraineEvent(loggedAt: Date())
                    lastLoggedEventID = newEvent.id
                    store.updateEvent(newEvent)
                    
                    showConfirmation = true
                    
                    // Auto-hide after 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showConfirmation = false
                    }
                }) {
                    VStack(spacing: Theme.Spacing.regular) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 60))
                        Text("Migraine Attack")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.jumbo)
                    .background(Theme.Colors.primaryAction)
                    .foregroundColor(Theme.Colors.inverseText)
                    .cornerRadius(Theme.CornerRadius.extraLarge)
                }
                .padding(.horizontal, Theme.Spacing.huge)
                
                Spacer()
            }
            .navigationTitle("Quick Log")
            .overlay(
                Group {
                    if showConfirmation {
                        VStack(spacing: Theme.Spacing.regular) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Theme.Colors.success)
                            Text("Saved")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Button(action: {
                                showConfirmation = false
                                showDetailsFlow = true
                            }) {
                                Text("Add Details")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, Theme.Spacing.large)
                                    .padding(.vertical, Theme.Spacing.medium)
                                    .background(Theme.Colors.primaryAction)
                                    .foregroundColor(Theme.Colors.inverseText)
                                    .cornerRadius(Theme.CornerRadius.medium)
                            }
                        }
                        .padding(Theme.Spacing.huge)
                        .background(Theme.Colors.cardBackground.opacity(0.98))
                        .cornerRadius(Theme.CornerRadius.extraLarge)
                        .shadow(color: Theme.Shadow.color, radius: Theme.Shadow.Radius.large)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            )
            .animation(.spring(), value: showConfirmation)
            .fullScreenCover(isPresented: $showDetailsFlow) {
                if let eventID = lastLoggedEventID {
                    AddAttackDetailsFlow(eventID: eventID, store: store)
                        .environmentObject(store)
                        .environmentObject(SettingsManager())
                }
            }
        }
    }
}

#Preview {
    QuickLogView()
        .environmentObject(MigraineStore())
}
