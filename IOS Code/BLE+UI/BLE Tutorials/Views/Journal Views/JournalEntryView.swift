//
//  JournalEntryView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/30/26.
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
                Text("New Journal Entry")
                    .font(.appSubHeader())
                    .smallPaddingBottom()
                HStack{
                    Image("logo_solidFill_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal)
                        
                    Spacer()
                    Text("\(timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .font(.appBody())
                    Spacer()
                    Image("logo_solidFill_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal)
                        .scaleEffect(x: -1, y: 1)
                }
                .smallPaddingBottom()
                
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



