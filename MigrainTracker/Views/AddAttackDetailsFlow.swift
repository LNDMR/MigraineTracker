//
//  AddAttackDetailsFlow.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct AddAttackDetailsFlow: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    let eventID: UUID
    @State private var selectedTab = 0
    @State private var event: MigraineEvent
    
    init(eventID: UUID, store: MigraineStore) {
        self.eventID = eventID
        if let existingEvent = store.event(withID: eventID) {
            _event = State(initialValue: existingEvent)
        } else {
            _event = State(initialValue: MigraineEvent(loggedAt: Date()))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text("Log Attack Details")
                    .font(.headline)
                Spacer()
                Button("Save") {
                    saveAndDismiss()
                }
                .fontWeight(.semibold)
            }
            .padding(Theme.Spacing.regular)
            .background(Theme.Colors.cardBackground)
            
            // MARK: - Progress Dots
            HStack(spacing: Theme.Spacing.small) {
                ForEach(0..<6) { index in
                    Circle()
                        .fill(index <= selectedTab ? Theme.Colors.primaryAction : Theme.Colors.disabledAction)
                        .frame(width: Theme.Size.dotSmall, height: Theme.Size.dotSmall)
                }
            }
            .padding(.vertical, Theme.Spacing.medium)
            
            // MARK: - Swipeable Content
            TabView(selection: $selectedTab) {
                OnsetView(timeOfDay: Binding(
                    get: { event.symptomsOnsetTime },
                    set: { event.symptomsOnsetTime = $0 }
                ))
                .tag(0)
                
                SeverityView(painLevel: Binding(
                    get: { event.painLevel },
                    set: { event.painLevel = $0 }
                ))
                .tag(1)
                
                SymptomsView(symptoms: Binding(
                    get: { event.symptoms ?? [] },
                    set: { event.symptoms = $0.isEmpty ? nil : $0 }
                ))
                .tag(2)
                
                DurationView(duration: Binding(
                    get: { event.duration },
                    set: { event.duration = $0 }
                ))
                .tag(3)
                
                MedicationView(
                    medications: Binding(
                        get: { event.medications },
                        set: { event.medications = $0 }
                    )
                )
                .tag(4)
                
                NotesView(notes: Binding(
                    get: { event.notes },
                    set: { event.notes = $0 }
                ))
                .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .interactiveDismissDisabled()
    }
    
    private func saveAndDismiss() {
        store.updateEvent(event)
        dismiss()
    }
}


#Preview {
    AddAttackDetailsFlow(eventID: UUID(), store: MigraineStore())
        .environmentObject(MigraineStore())
        .environmentObject(SettingsManager())
}
