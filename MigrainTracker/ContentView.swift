//
//  ContentView.swift
//  MigrainTracker
//
//  Created by Linda Kötter on 15.01.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "bolt.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Track Migraine!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
