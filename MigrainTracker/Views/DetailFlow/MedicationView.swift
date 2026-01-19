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
    @Binding var medication: String?
    @Binding var medicationHelped: Bool?
    @State private var showHelped: Bool = false
    @State private var showMedicationPicker = false
    @State private var selectedMedication: String?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("Which medication brought relief?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
                .padding(.horizontal)
            
            if !settingsManager.hasConfiguredMedications {
                // No medications configured - show setup prompt
                Spacer()
                
                VStack(spacing: Theme.Spacing.large) {
                    Image(systemName: "pills.circle")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.Colors.primaryAction.opacity(0.5))
                    
                    Text("Customize your medication list")
                        .font(.headline)
                    
                    Text("Select the medications you use to make logging faster")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                    
                    Button {
                        showMedicationPicker = true
                    } label: {
                        Text("Set Up Medications")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.regular)
                            .background(Theme.Colors.primaryAction)
                            .foregroundColor(Theme.Colors.inverseText)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }
                    .padding(.horizontal, Theme.Spacing.huge)
                }
                
                Spacer()
            } else {
                // Show medication list
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.medium) {
                            ForEach(settingsManager.medicationsToDisplay, id: \.self) { med in
                                MedicationButton(
                                    medication: med,
                                    isSelected: selectedMedication == med,
                                    action: {
                                        selectedMedication = med
                                        medication = med
                                        showHelped = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.extraLarge)
                        .padding(.bottom, Theme.Spacing.medium)
                    }
                    
                    // Subtle manage button at bottom
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
                    
                    // Did it help?
                    if showHelped {
                        Divider()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            Text("Did it help?")
                                .font(.headline)
                                .padding(.horizontal, Theme.Spacing.extraLarge)
                                .padding(.top, Theme.Spacing.medium)
                            
                            HStack(spacing: Theme.Spacing.regular) {
                                Button(action: {
                                    medicationHelped = true
                                }) {
                                    VStack(spacing: Theme.Spacing.small) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(medicationHelped == true ? Theme.Colors.inverseText : Theme.Colors.success)
                                        
                                        Text("Yes")
                                            .font(.headline)
                                            .foregroundColor(medicationHelped == true ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Theme.Spacing.large)
                                    .background(medicationHelped == true ? Theme.Colors.success : Theme.Colors.secondaryBackground)
                                    .cornerRadius(Theme.CornerRadius.large)
                                }
                                
                                Button(action: {
                                    medicationHelped = false
                                }) {
                                    VStack(spacing: Theme.Spacing.small) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(medicationHelped == false ? Theme.Colors.inverseText : Theme.Colors.error)
                                        
                                        Text("No")
                                            .font(.headline)
                                            .foregroundColor(medicationHelped == false ? Theme.Colors.inverseText : Theme.Colors.primaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Theme.Spacing.large)
                                    .background(medicationHelped == false ? Theme.Colors.error : Theme.Colors.secondaryBackground)
                                    .cornerRadius(Theme.CornerRadius.large)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.extraLarge)
                        }
                        .padding(.bottom, Theme.Spacing.medium)
                    }
                }
            }
        }
        .sheet(isPresented: $showMedicationPicker) {
            MedicationPickerView(isSheet: true)
                .environmentObject(settingsManager)
        }
        .onAppear {
            showHelped = medication != nil && !medication!.isEmpty
            selectedMedication = medication
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
    MedicationView(
        medication: .constant("Ibuprofen"),
        medicationHelped: .constant(true)
    )
    .environmentObject(MigraineStore())
    .environmentObject(SettingsManager())
}
