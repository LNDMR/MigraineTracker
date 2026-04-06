//
//  SymptomPickerView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import SwiftUI

struct SymptomPickerView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedSymptoms: Set<String> = []
    @State private var customSymptoms: [String] = []
    @State private var newSymptomName: String = ""
    @State private var showAddField: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var isSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                // Default Symptoms Section
                Section {
                    ForEach(AppSettings.defaultSymptoms, id: \.self) { symptom in
                        symptomRow(symptom: symptom)
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Common Symptoms")
                        Text("Select the symptoms you typically experience")
                            .font(.caption)
                            .textCase(.none)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                // Custom Symptoms Section
                Section {
                    ForEach(customSymptoms, id: \.self) { symptom in
                        symptomRow(symptom: symptom)
                    }
                    .onDelete(perform: deleteCustomSymptom)
                    
                    // Inline text field when adding
                    if showAddField {
                        HStack {
                            TextField("Enter symptom name", text: $newSymptomName)
                                .focused($isTextFieldFocused)
                                .autocapitalization(.words)
                                .submitLabel(.done)
                                .onSubmit {
                                    addCustomSymptom()
                                }
                            
                            if !newSymptomName.isEmpty {
                                Button {
                                    addCustomSymptom()
                                } label: {
                                    Text("Add")
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.Colors.primaryAction)
                                }
                            }
                            
                            Button {
                                cancelAddSymptom()
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                    }
                    
                    // Add custom symptom button
                    if !showAddField {
                        Button {
                            showAddField = true
                            isTextFieldFocused = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.Colors.primaryAction)
                                Text("Add Custom Symptom")
                                    .foregroundColor(Theme.Colors.primaryAction)
                            }
                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Symptoms")
                        if !customSymptoms.isEmpty {
                            Text("Swipe left on any cutom item to delete")
                                .font(.caption)
                                .textCase(.none)
                                .foregroundColor(Theme.Colors.secondaryText)
                        } else {
                            Text("Add your own specific symptoms")
                                .font(.caption)
                                .textCase(.none)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                    }
                }
            }
            .navigationTitle("Manage Symptoms")
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
    private func symptomRow(symptom: String) -> some View {
        Button(action: {
            toggleSymptom(symptom)
        }) {
            HStack {
                Text(symptom)
                    .foregroundColor(Theme.Colors.primaryText)
                Spacer()
                if selectedSymptoms.contains(symptom) {
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
    
    private func toggleSymptom(_ symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
    
    private func addCustomSymptom() {
        let trimmed = newSymptomName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        // Check if it already exists (case-insensitive)
        let lowercased = trimmed.lowercased()
        let allExisting = (AppSettings.defaultSymptoms + customSymptoms).map { $0.lowercased() }
        
        if !allExisting.contains(lowercased) {
            customSymptoms.append(trimmed)
            customSymptoms.sort()
            selectedSymptoms.insert(trimmed) // Auto-select new custom symptom
        }
        
        newSymptomName = ""
        showAddField = false
    }
    
    private func cancelAddSymptom() {
        newSymptomName = ""
        showAddField = false
        isTextFieldFocused = false
    }
    
    private func deleteCustomSymptom(at offsets: IndexSet) {
        for index in offsets {
            let symptom = customSymptoms[index]
            selectedSymptoms.remove(symptom)
        }
        customSymptoms.remove(atOffsets: offsets)
    }
    
    private func loadCurrentSettings() {
        selectedSymptoms = Set(settingsManager.settings.selectedSymptoms)
        customSymptoms = settingsManager.settings.customSymptoms
    }
    
    private func saveChanges() {
        settingsManager.settings.selectedSymptoms = Array(selectedSymptoms).sorted()
        settingsManager.settings.customSymptoms = customSymptoms
        settingsManager.save()
        dismiss()
    }
}

#Preview {
    SymptomPickerView()
        .environmentObject(SettingsManager())
}
