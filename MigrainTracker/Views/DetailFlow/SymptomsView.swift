//
//  SymptomsView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct SymptomsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var symptoms: [String]
    @State private var selectedSymptoms: Set<String> = []
    @State private var showSymptomPicker = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("Which symptoms did you experience?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
            
            if !settingsManager.hasConfiguredSymptoms {
                // No symptoms configured - show setup prompt
                
                VStack(spacing: Theme.Spacing.large) {
                    Text("Only see the symptoms that matter to you")
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                    
                    Button {
                        showSymptomPicker = true
                    } label: {
                        Text("Choose Symptoms")
                            .fontWeight(.medium)
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
                // Show symptoms list
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.medium) {
                            ForEach(settingsManager.symptomsToDisplay, id: \.self) { symptom in
                                SymptomRow(
                                    symptom: symptom,
                                    isSelected: selectedSymptoms.contains(symptom)
                                ) {
                                    if selectedSymptoms.contains(symptom) {
                                        selectedSymptoms.remove(symptom)
                                    } else {
                                        selectedSymptoms.insert(symptom)
                                    }
                                    symptoms = Array(selectedSymptoms)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.extraLarge)
                        .padding(.bottom, Theme.Spacing.medium)
                    }
                    
                    // Subtle manage button at bottom
                    Button {
                        showSymptomPicker = true
                    } label: {
                        HStack(spacing: Theme.Spacing.small) {
                            Image(systemName: "gear")
                                .font(.caption)
                            Text("Manage Symptoms")
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
        .sheet(isPresented: $showSymptomPicker) {
            SymptomPickerView(isSheet: true)
                .environmentObject(settingsManager)
        }
        .onAppear {
            selectedSymptoms = Set(symptoms)
        }
    }
}

struct SymptomRow: View {
    let symptom: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(symptom)
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
    NavigationStack {
        SymptomsView(symptoms: .constant(["Nausea"]))
            .environmentObject(SettingsManager())
    }
}
