//
//  MedicationView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct MedicationView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var medications: [MigraineEvent.MedicationEntry]
    @State private var showMedicationPicker = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("Which medications did you take?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
                .padding(.horizontal)
            
            if !settingsManager.hasConfiguredMedications {
                VStack(spacing: Theme.Spacing.large) {
                    Text("Only see the medications you actually take")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                    
                    Button {
                        showMedicationPicker = true
                    } label: {
                        Text("Choose Medications")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.small)
                            .background(Theme.Colors.primaryAction)
                            .foregroundColor(Theme.Colors.inverseText)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }
                    .padding(.horizontal, Theme.Spacing.huge)
                }
                
                Spacer()
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.medium) {
                            ForEach(settingsManager.medicationsToDisplay, id: \.self) { med in
                                VStack(spacing: Theme.Spacing.small) {
                                    MedicationButton(
                                        medication: med,
                                        isSelected: isSelected(med),
                                        action: {
                                            toggleMedication(med)
                                        }
                                    )
                                    
                                    if let entry = medications.first(where: { $0.name == med }) {
                                        helpedRow(for: entry)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.extraLarge)
                        .padding(.bottom, Theme.Spacing.medium)
                    }
                    
                    Button {
                        showMedicationPicker = true
                    } label: {
                        HStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "gear")
                                .font(.caption)
                            Text("Manage Medications")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Theme.Colors.secondaryText)
                        .padding(.vertical, Theme.Spacing.small)
                    }
                    .padding(.bottom, Theme.Spacing.medium)
                }
            }
        }
        .sheet(isPresented: $showMedicationPicker) {
            MedicationPickerView(isSheet: true)
                .environmentObject(settingsManager)
        }
    }
    
    private func isSelected(_ name: String) -> Bool {
        medications.contains { $0.name == name }
    }
    
    private func toggleMedication(_ name: String) {
        if let index = medications.firstIndex(where: { $0.name == name }) {
            medications.remove(at: index)
        } else {
            medications.append(MigraineEvent.MedicationEntry(name: name, helped: nil))
        }
    }
    
    @ViewBuilder
    private func helpedRow(for entry: MigraineEvent.MedicationEntry) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Did \(entry.name) help?")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.Colors.primaryText)
            
            HStack(spacing: Theme.Spacing.small) {
                Button {
                    setHelped(true, for: entry)
                } label: {
                    Text("Yes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(entry.helped == true ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.small)
                        .background(entry.helped == true ? Theme.Colors.success : Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                
                Button {
                    setHelped(false, for: entry)
                } label: {
                    Text("No")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(entry.helped == false ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.small)
                        .background(entry.helped == false ? Theme.Colors.error : Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
            }
        }
        .padding(Theme.Spacing.regular)
        .background(Theme.Colors.secondaryBackground.opacity(0.5))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private func setHelped(_ value: Bool, for entry: MigraineEvent.MedicationEntry) {
        if let index = medications.firstIndex(where: { $0.id == entry.id }) {
            medications[index].helped = value
        }
    }
}

// MARK: - Medication Button

private struct MedicationButton: View {
    let medication: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "pills")
                    .foregroundColor(isSelected ? Theme.Colors.inverseText : Theme.Colors.primaryAction)
                Text(medication)
                    .font(.body)
                    .foregroundColor(isSelected ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.inverseText)
                }
            }
            .padding(Theme.Spacing.regular)
            .background(isSelected ? Theme.Colors.primaryAction : Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
}

#Preview {
    MedicationView(medications: .constant([
        MigraineEvent.MedicationEntry(name: "Ibuprofen", helped: true)
    ]))
    .environmentObject(MigraineStore())
    .environmentObject(SettingsManager())
}
