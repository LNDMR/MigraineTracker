//
//  NotesView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 16.01.26.
//

import SwiftUI

struct NotesView: View {
    @Binding var notes: String?
    @State private var notesText: String = ""
    
    var body: some View {
        VStack(spacing: Theme.Spacing.jumbo) {
            Text("Any additional notes to add?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                ZStack(alignment: .topLeading) {
                    
                    TextEditor(text: $notesText)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 100, maxHeight: 160)
                        .padding(Theme.Spacing.small)
                        .onChange(of: notesText) { _, newValue in
                            notes = newValue.isEmpty ? nil : newValue
                        }
                }
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            .padding(.horizontal, Theme.Spacing.extraLarge)
            
            Spacer()
        }
        .onAppear {
            notesText = notes ?? ""
        }
    }
}

#Preview {
    NotesView(notes: .constant("Stressed at work"))
}
