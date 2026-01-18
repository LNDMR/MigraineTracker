//
//  MedicationView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct MedicationView: View {
    @EnvironmentObject var store: MigraineStore
    @Binding var medication: String?
    @Binding var medicationHelped: Bool?
    @State private var medicationText: String = ""
    @State private var showHelped: Bool = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("Which activities or medications brought relief?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    // Medication Input
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Text("Medication")
                            .font(.headline)
                            .padding(.horizontal, Theme.Spacing.extraLarge)
                        
                        TextField("e.g., Ibuprofen 400mg", text: $medicationText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, Theme.Spacing.extraLarge)
                            .onChange(of: medicationText) { _, newValue in
                                medication = newValue.isEmpty ? nil : newValue
                                showHelped = !newValue.isEmpty
                            }
                        
                        if !store.usedMedications.isEmpty && medicationText.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                                Text("Previously used:")
                                    .font(.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                    .padding(.horizontal, Theme.Spacing.extraLarge)
                                
                                ForEach(store.usedMedications.prefix(3), id: \.self) { med in
                                    Button(action: {
                                        medicationText = med
                                        medication = med
                                        showHelped = true
                                    }) {
                                        HStack {
                                            Image(systemName: "pills")
                                                .foregroundColor(Theme.Colors.primaryAction)
                                            Text(med)
                                                .foregroundColor(Theme.Colors.primaryText)
                                            Spacer()
                                            Image(systemName: "arrow.turn.down.left")
                                                .font(.caption)
                                                .foregroundColor(Theme.Colors.secondaryText)
                                        }
                                        .padding(Theme.Spacing.regular)
                                        .background(Theme.Colors.secondaryBackground)
                                        .cornerRadius(Theme.CornerRadius.medium)
                                    }
                                    .padding(.horizontal, Theme.Spacing.extraLarge)
                                }
                            }
                        }
                    }
                    
                    // Did it help?
                    if showHelped {
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            Text("Did it help?")
                                .font(.headline)
                                .padding(.horizontal, Theme.Spacing.extraLarge)
                            
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
                    }
                }
            }
        }
        .onAppear {
            medicationText = medication ?? ""
            showHelped = medication != nil && !medication!.isEmpty
        }
    }
}

#Preview {
    MedicationView(
        medication: .constant("Ibuprofen 400mg"),
        medicationHelped: .constant(true)
    )
    .environmentObject(MigraineStore())
}
