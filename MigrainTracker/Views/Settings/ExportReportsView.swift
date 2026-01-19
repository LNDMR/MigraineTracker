//
//  ExportReportsView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct ExportReportsView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showClearAlert = false
    @State private var showPDFExport = false
    @State private var showCSVExport = false
    
    var body: some View {
        Form {
            Section {
                TextField("Your Name", text: $settingsManager.settings.name)
                    .onChange(of: settingsManager.settings.name) { _, _ in
                        settingsManager.save()
                    }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name for Reports")
                    Text("Appears in the header of exported PDF reports")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            Section {
                Button(action: {
                    showPDFExport = true
                }) {
                    Label("Export to PDF", systemImage: "doc.text")
                }
                
                Button(action: {
                    showCSVExport = true
                }) {
                    Label("Export to CSV", systemImage: "tablecells")
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Data")
                    Text("Export your migraine data for doctor appointments or personal analysis")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    showClearAlert = true
                }) {
                    Label("Clear All Data", systemImage: "trash")
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Delete All Data")
                    Text("Permanently deletes all logged attacks. This cannot be undone.")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Export & Reports")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Data?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                store.clearAllEvents()
            }
        } message: {
            Text("This will permanently delete all \(store.events.count) migraine attacks. This action cannot be undone.")
        }
        .sheet(isPresented: $showPDFExport) {
            DateRangePickerView(exportType: .pdf)
        }
        .sheet(isPresented: $showCSVExport) {
            DateRangePickerView(exportType: .csv)
        }
    }
}

// MARK: - DateRangePickerView (Placeholder)
struct DateRangePickerView: View {
    @EnvironmentObject var store: MigraineStore
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    let exportType: ExportType
    @State private var dateRange: DateRangeOption = .all
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Date Range") {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(DateRangeOption.allCases, id: \.self) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    
                    if dateRange == .custom {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    }
                }
                
                Section {
                    Button("Export \(exportType.label)") {
                        performExport()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Export \(exportType.label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func performExport() {
        // TODO: Implement actual PDF/CSV generation
        print("Exporting \(exportType.label) for range: \(dateRange.label)")
    }
}

// MARK: - Supporting Enums
enum ExportType {
    case pdf, csv
    
    var label: String {
        switch self {
        case .pdf: return "PDF"
        case .csv: return "CSV"
        }
    }
}

enum DateRangeOption: String, CaseIterable, Codable {
    case all
    case lastMonth
    case lastSixMonths
    case custom
    
    var label: String {
        switch self {
        case .all: return "All Time"
        case .lastMonth: return "Last Month"
        case .lastSixMonths: return "Last 6 Months"
        case .custom: return "Custom Range"
        }
    }
}

#Preview {
    NavigationStack {
        ExportReportsView()
            .environmentObject(MigraineStore())
            .environmentObject(SettingsManager())
    }
}
