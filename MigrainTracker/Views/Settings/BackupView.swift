//
//  BackupView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupView: View {
    @EnvironmentObject var store: MigraineStore
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var showImportAlert = false
    @State private var backupFileURL: URL?
    @State private var importedEvents: [MigraineEvent] = []
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "checkmark.icloud")
                        .foregroundColor(Theme.Colors.success)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: Theme.Spacing.tiny) {
                        Text("iCloud Backup Active")
                            .font(.headline)
                        Text("Data synced automatically")
                            .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Automatic iCloud Backup")
                    Text("Your data automatically saves to iCloud when iCloud Drive is enabled")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
            
            Section {
                Button(action: {
                    exportBackup()
                }) {
                    Label("Export Backup File", systemImage: "square.and.arrow.up")
                }
                
                Button(action: {
                    showImportPicker = true
                }) {
                    Label("Import Backup File", systemImage: "square.and.arrow.down")
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manual Backup")
                    Text("Save or restore a backup file manually for extra safety")
                        .font(.caption)
                        .textCase(.none)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
            }
        }
        .navigationTitle("Backup")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExportSheet) {
            if let url = backupFileURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
        .alert("Import Backup?", isPresented: $showImportAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Replace All Data", role: .destructive) {
                store.importEvents(importedEvents)
            }
        } message: {
            Text("This will replace all current data (\(store.events.count) attacks) with \(importedEvents.count) attacks from the backup file.")
        }
    }
    
    private func exportBackup() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(store.events)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
            let dateString = dateFormatter.string(from: Date())
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("migraine_backup_\(dateString).json")
            try data.write(to: tempURL)
            
            backupFileURL = tempURL
            showExportSheet = true
        } catch {
            print("❌ Export failed: \(error)")
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            
            // Start accessing security-scoped resource
            guard selectedFile.startAccessingSecurityScopedResource() else { return }
            defer { selectedFile.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: selectedFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            importedEvents = try decoder.decode([MigraineEvent].self, from: data)
            
            // Show confirmation alert
            showImportAlert = true
            
        } catch {
            print("❌ Import failed: \(error)")
        }
    }
}

// MARK: - ShareSheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        BackupView()
            .environmentObject(MigraineStore())
    }
}
