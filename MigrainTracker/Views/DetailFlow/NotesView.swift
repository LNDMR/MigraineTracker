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
            Text("Any additional notes you want to add?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, Theme.Spacing.huge)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                TextEditor(text: $notesText)
                    .frame(height: 200)
                    .padding(Theme.Spacing.small)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.medium)
                    .onChange(of: notesText) { _, newValue in
                        notes = newValue.isEmpty ? nil : newValue
                    }
                
                Text("Optional: Add triggers, activities, or anything else relevant")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
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
