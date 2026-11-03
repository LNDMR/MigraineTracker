//
//  EventDetailView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("promptForDetails") private var promptForDetails = true
    
    let eventID: UUID
    
    @State private var showEditFlow = false
    @State private var showDeleteAlert = false
    @State private var showDateEditor = false
    @State private var editingDate = Date()
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var editorMonth: Date = Date()
    @State private var editorWeekCount: Int = 6
    
    // Computed property that always gets fresh data from store
    private var event: MigraineEvent? {
        store.event(withID: eventID)
    }
    
    private var isToday: Bool {
        guard let event = event else { return false }
        return Calendar.current.isDateInToday(event.loggedAt)
    }
    
    var body: some View {
        Group {
            if let event = event {
                eventContent(event)
            } else {
                // Event was deleted
                ContentUnavailableView(
                    "Event Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This migraine event no longer exists")
                )
            }
        }
        .navigationTitle("Migraine Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if event != nil, promptForDetails {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditFlow = true
                        } label: {
                            Label("Edit Details", systemImage: "pencil")
                        }
                        
                        Button {
                            editingDate = event?.loggedAt ?? Date()
                            showDateEditor = true
                        } label: {
                            Label("Change Date", systemImage: "calendar")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showEditFlow) {
            AddAttackDetailsFlow(eventID: eventID, store: store)
                .environmentObject(store)
                .environmentObject(settingsManager)
        }
        .sheet(isPresented: $showDateEditor) {
            dateEditorSheet
        }
        .alert("Cannot Change Date", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .alert("Delete Migraine Event?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let event = event {
                    store.deleteEvent(event)
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    private func eventContent(_ event: MigraineEvent) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                // Date Header - Display only, not tappable
                Text(event.loggedAt.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Show details only if promptForDetails is ON
                if promptForDetails {
                    if !event.hasDetails {
                        noDetailsPrompt
                    } else {
                        detailsContent(for: event)
                    }
                }
            }
            .padding(Theme.Spacing.large)
        }
    }
    
    // MARK: - No Details Prompt
    
    private var noDetailsPrompt: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.large) {
            Text("No details logged yet")
                .font(.headline)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Button {
                showEditFlow = true
            } label: {
                Text("Add Details")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.small)
                    .background(Theme.Colors.primaryAction)
                    .cornerRadius(Theme.CornerRadius.medium)
            }
        }
    }
    
    // MARK: - Details Content
    
    @ViewBuilder
    private func detailsContent(for event: MigraineEvent) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            
            if let onset = event.symptomsOnsetTime {
                detailRow(icon: onset.icon, label: "Onset", value: onset.label)
                Divider()
            }
            
            if let duration = event.duration {
                detailRow(icon: iconForDuration(duration), label: "Duration", value: duration.label)
                Divider()
            }
            
            if let painLevel = event.painLevel {
                HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                    Image(systemName: "bolt.fill")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryAction)
                        .frame(width: 20)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Pain level")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                        Text(painLevel.label)
                            .font(.body)
                            .foregroundColor(Theme.Colors.primaryText)
                        Text(painDescription(for: painLevel))
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                .padding(.vertical, Theme.Spacing.small)
                
                Divider()
            }
            
            // Symptoms — badges in a wrapping layout, heartbeat icon
            if let symptoms = event.symptoms, !symptoms.isEmpty {
                HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryAction)
                        .frame(width: 20)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Symptoms")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                        
                        FlowLayout(spacing: 6) {
                            ForEach(symptoms, id: \.self) { symptom in
                                Text(symptom)
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.primaryText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Theme.Colors.secondaryBackground)
                                    .cornerRadius(Theme.CornerRadius.medium)
                            }
                        }
                    }
                }
                .padding(.vertical, Theme.Spacing.small)
                
                Divider()
            }
            
            if !event.medications.isEmpty {
                HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                    Image(systemName: "pills")
                        .font(.body)
                        .foregroundColor(Theme.Colors.primaryAction)
                        .frame(width: 20)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Medication")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(event.medications) { entry in
                                (Text(entry.name)
                                    .foregroundColor(Theme.Colors.primaryText)
                                 + Text(medicationSuffix(for: entry))
                                    .foregroundColor(entry.helped == true ? Theme.Colors.success : Theme.Colors.error)
                                )
                                .font(.body)
                            }
                        }
                    }
                }
                .padding(.vertical, Theme.Spacing.small)
                
                Divider()
            }
            
            if let notes = event.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Notes")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                    Text(notes)
                        .font(.body)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .lineSpacing(4)
                }
                .padding(.vertical, Theme.Spacing.small)
            }
        }
    }

    @ViewBuilder
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Theme.Colors.primaryAction)
                .frame(width: 20)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(Theme.Colors.secondaryText)
                Text(value)
                    .font(.body)
                    .foregroundColor(Theme.Colors.primaryText)
            }
        }
        .padding(.vertical, Theme.Spacing.small)
    }

    private func iconForDuration(_ duration: MigraineEvent.Duration) -> String {
        switch duration {
        case .short: return "clock"
        case .medium: return "clock.badge.checkmark"
        case .long: return "clock.arrow.circlepath"
        case .veryLong: return "hourglass"
        }
    }

    private func medicationSuffix(for entry: MigraineEvent.MedicationEntry) -> String {
        guard let helped = entry.helped else { return "" }
        return helped ? " — helped" : " — didn't help"
    }
    
    // Convert pain description to past tense if not today
    private func painDescription(for level: MigraineEvent.PainLevel) -> String {
        if isToday {
            return level.description
        }
        
        // Convert to past tense
        switch level {
        case .mild:
            return "I was able to go about my day"
        case .moderate:
            return "I was limited in what I could do"
        case .severe:
            return "I was completely out of action"
        }
    }

    private var dateEditorSheet: some View {
        VStack(spacing: Theme.Spacing.large) {
            HStack {
                Button("Cancel") {
                    showDateEditor = false
                }
                .foregroundColor(Theme.Colors.primaryAction)
                
                Spacer()
                
                Button("Save") {
                    saveDateChange()
                }
                .foregroundColor(Theme.Colors.primaryAction)
                .fontWeight(.semibold)
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.top, Theme.Spacing.large)
            
            MonthGridView(
                currentMonth: $editorMonth,
                hasEvent: { date in
                    store.events.contains { Calendar.current.isDate($0.loggedAt, inSameDayAs: date) }
                },
                isSelected: { date in
                    Calendar.current.isDate(date, inSameDayAs: editingDate)
                },
                isDisabled: { date in
                    // Only disabled if a DIFFERENT entry occupies this date —
                    // the event's own current date should stay tappable (it's a no-op, not a conflict)
                    guard let match = store.events.first(where: {
                        Calendar.current.isDate($0.loggedAt, inSameDayAs: date)
                    }) else { return false }
                    return match.id != eventID
                },
                onSelectDate: { date in
                    editingDate = date
                },
                onWeekCountChange: { weeks in
                    editorWeekCount = weeks
                }
            )
            
            Spacer()
        }
        .onAppear {
            editorMonth = editingDate
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.visible)
    }
    
    private var sheetHeight: CGFloat {
        let baseHeight: CGFloat = 180 // Cancel/Save row + month nav + weekday header + paddings
        let rowHeight: CGFloat = Theme.Size.touchTarget + Theme.Spacing.small
        return baseHeight + (CGFloat(editorWeekCount) * rowHeight)
    }
    
    private func saveDateChange() {
        guard var updatedEvent = event else { return }
        
        // Combine new date with original time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: editingDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: updatedEvent.loggedAt)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        let newDate = calendar.date(from: combined) ?? editingDate
        
        // Validate: Check if another event exists on this date (excluding current event)
        // Kept as a safety net — the grid's isDisabled should make this unreachable in normal use.
        let conflictingEvent = store.events.first { otherEvent in
            otherEvent.id != eventID && calendar.isDate(otherEvent.loggedAt, inSameDayAs: newDate)
        }
        
        if let conflict = conflictingEvent {
            validationMessage = "A migraine is already logged for \(newDate.formatted(date: .long, time: .omitted)). Delete that event first if you want to move this one there."
            showValidationError = true
            return
        }
        
        // Update event with new date but keep original time
        updatedEvent.loggedAt = newDate
        store.updateEvent(updatedEvent)
        
        // Close sheet
        showDateEditor = false
    }
    
    private func severityColor(for level: MigraineEvent.PainLevel) -> Color {
        level.color
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentRowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth, currentRowWidth > 0 {
                totalHeight += currentRowHeight + spacing
                currentRowWidth = size.width + spacing
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        totalHeight += currentRowHeight
        
        return CGSize(width: maxWidth == .infinity ? currentRowWidth : maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += currentRowHeight + spacing
                currentRowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}
