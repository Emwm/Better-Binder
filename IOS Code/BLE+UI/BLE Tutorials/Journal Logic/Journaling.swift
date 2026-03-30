//
//  Journaling.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-29.
//

import Foundation
import SwiftUI

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var text: String
    var date: Date
}

struct NewEntryView: View {
    @State private var entryText: String = ""
    
    // We capture the exact time the user opened this screen
    private let timestamp = Date.now
    
    @Binding var entries: [JournalEntry]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack{
                Image("bBird")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                // Show the user the time, but don't let them edit it
                Text("New Journal Entry")
                    .font(.system(.title))
                    .padding(5)
                Text("Entry for \(timestamp.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 20))
                    .padding(.horizontal)
                ZStack{
                    TextEditor(text: $entryText)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Captures the time the button was actually tapped
                        let newEntry = JournalEntry(text: entryText, date: .now)
                        entries.append(newEntry)
                        dismiss()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
#Preview {
    // You pass a "hardcoded" empty array wrapped in a constant binding
    NewEntryView(entries: .constant([]))
}



