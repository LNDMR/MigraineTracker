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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AppSettings.allSymptoms, id: \.self) { symptom in
                        Button(action: {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                            }
                        }) {
                            HStack {
                                Text(symptom)
                                    .foregroundColor(Theme.Colors.primaryText)
                                Spacer()
                                if selectedSymptoms.contains(symptom) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Theme.Colors.primaryAction)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Select Your Symptoms")
                } footer: {
                    Text("Choose the symptoms you typically experience. These will appear when logging attacks.")
                }
            }
            .navigationTitle("Customize Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        settingsManager.settings.selectedSymptoms = Array(selectedSymptoms).sorted()
                        settingsManager.save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Load current selection when view appears
                selectedSymptoms = Set(settingsManager.settings.selectedSymptoms)
            }
        }
    }
}

#Preview {
    SymptomPickerView()
        .environmentObject(SettingsManager())
}
