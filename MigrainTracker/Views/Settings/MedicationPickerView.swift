//
//  MedicationPickerView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 18.01.26.
//

import SwiftUI

struct MedicationPickerView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMedications: Set<String> = []
    @State private var customMedications: [String] = []
    @State private var newMedicationName: String = ""
    @State private var showAddField: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var isSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                // Default Medications Section
                Section {
                    ForEach(AppSettings.defaultMedications, id: \.self) { medication in
                        medicationRow(medication: medication)
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Common Medications")
                        Text("Select the medications you use for migraines")
                            .font(.caption)
                            .textCase(.none)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                // Custom Medications Section
                Section {
                    ForEach(customMedications, id: \.self) { medication in
                        medicationRow(medication: medication)
                    }
                    .onDelete(perform: deleteCustomMedication)
                    
                    // Inline text field when adding
                    if showAddField {
                        HStack {
                            TextField("Enter medication name", text: $newMedicationName)
                                .focused($isTextFieldFocused)
                                .autocapitalization(.words)
                                .submitLabel(.done)
                                .onSubmit {
                                    addCustomMedication()
                                }
                            
                            if !newMedicationName.isEmpty {
                                Button {
                                    addCustomMedication()
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.Colors.success)
                                }
                            }
                            
                            Button {
                                cancelAddMedication()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                    }
                    
                    // Add custom medication button
                    if !showAddField {
                        Button {
                            showAddField = true
                            isTextFieldFocused = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.Colors.primaryAction)
                                Text("Add Custom Medication")
                                    .foregroundColor(Theme.Colors.primaryAction)
                            }
                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Medications")
                        if !customMedications.isEmpty {
                            Text("Swipe left on any cutom item to delete")
                                .font(.caption)
                                .textCase(.none)
                                .foregroundColor(Theme.Colors.secondaryText)
                        } else {
                            Text("Add your own specific medications")
                                .font(.caption)
                                .textCase(.none)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                    }
                }
            }
            .navigationTitle("Manage Medications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isSheet {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func medicationRow(medication: String) -> some View {
        Button(action: {
            toggleMedication(medication)
        }) {
            HStack {
                Text(medication)
                    .foregroundColor(Theme.Colors.primaryText)
                Spacer()
                if selectedMedications.contains(medication) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primaryAction)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleMedication(_ medication: String) {
        if selectedMedications.contains(medication) {
            selectedMedications.remove(medication)
        } else {
            selectedMedications.insert(medication)
        }
    }
    
    private func addCustomMedication() {
        let trimmed = newMedicationName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        // Check if it already exists (case-insensitive)
        let lowercased = trimmed.lowercased()
        let allExisting = (AppSettings.defaultMedications + customMedications).map { $0.lowercased() }
        
        if !allExisting.contains(lowercased) {
            customMedications.append(trimmed)
            customMedications.sort()
            selectedMedications.insert(trimmed) // Auto-select new custom medication
        }
        
        newMedicationName = ""
        showAddField = false
    }
    
    private func cancelAddMedication() {
        newMedicationName = ""
        showAddField = false
        isTextFieldFocused = false
    }
    
    private func deleteCustomMedication(at offsets: IndexSet) {
        for index in offsets {
            let medication = customMedications[index]
            selectedMedications.remove(medication)
        }
        customMedications.remove(atOffsets: offsets)
    }
    
    private func loadCurrentSettings() {
        selectedMedications = Set(settingsManager.settings.selectedMedications)
        customMedications = settingsManager.settings.customMedications
    }
    
    private func saveChanges() {
        settingsManager.settings.selectedMedications = Array(selectedMedications).sorted()
        settingsManager.settings.customMedications = customMedications
        settingsManager.save()
        dismiss()
    }
}

#Preview {
    MedicationPickerView()
        .environmentObject(SettingsManager())
}
