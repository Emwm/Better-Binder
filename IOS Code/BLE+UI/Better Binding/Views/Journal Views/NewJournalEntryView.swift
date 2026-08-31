//
//  NewJournalEntryView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/30/26.
//

import Foundation
import SwiftUI
import SwiftData

struct NewEntryView: View {
    @State private var entryText: String = ""
    @State private var physicalScore: Double = 5.0 // Default middle value
    @State private var mentalScore: Double = 5.0   // Default middle value
    
    // capture the exact time the user opened this screen
    private let timestamp = Date.now
    
    @Binding var entries: [JournalEntry]
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Image("logo_solidOutline_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal)
                    Spacer()
                    VStack{
                        Text("New Journal Entry")
                            .font(.appSubHeader())
                            .smallPaddingBottom()
                        Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.appSmallCaption())
                    }
                    Spacer()
                    Image("logo_solidOutline_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal)
                        .scaleEffect(x: -1, y: 1)
                }
                .mediumPaddingTop()
                .largePaddingBottom()
                .padding(.horizontal)
                
                //Physical
                VStack(alignment: .center) {
                    Text("Physical Wellness:")
                        .font(.appBody())
                    Text("\(Int(physicalScore)) / 10")
                        .font(.appSmallCaption())
                        .smallPaddingTop()
                    
                    // slider
                    HStack {
                        Text("0")
                            .font(.appSmallCaption())
                        Slider(value: $physicalScore, in: 0...10, step: 1)
                            .accentColor(.colorDarkCoral)
                        Text("10")
                            .font(.appSmallCaption())
                    }
                }
                .padding(.horizontal)
                .smallPaddingBottom()
                
                //Emotional
                VStack(alignment: .center) {
                    Text("Emotional Wellness:")
                        .font(.appBody())
                    Text("\(Int(mentalScore)) / 10")
                        .font(.appSmallCaption())
                        .smallPaddingTop()
                    // slider
                    HStack {
                        Text("0")
                            .font(.appSmallCaption())
                        Slider(value: $mentalScore, in: 0...10, step: 1)
                            .accentColor(.colorDarkCoral)
                        Text("10")
                            .font(.appSmallCaption())
                    }
                }
                .padding(.horizontal)
                .mediumPaddingBottom()
                
                //reflection
                Text("Notes:")
                    .font(.appBody())
                
                ZStack(alignment: .topLeading){
                    TextEditor(text: $entryText)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    if entryText.isEmpty {
                        Text("_How did binding feel today?_")
                            .foregroundColor(.gray)
                            .font(.appBody())
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Captures the time the button was actually tapped
                        let newEntry = JournalEntry(
                            timestamp: timestamp,
                            text: entryText,
                            physicalWellness: Int(physicalScore),
                            mentalWellness: Int(mentalScore)
                        )
                        modelContext.insert(newEntry)
                        try? modelContext.save()
                        dismiss()
                    }
//                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: JournalEntry.self, configurations: config)
        return NewEntryView(entries: .constant([]))
            .modelContainer(container)
    } catch {
        return NewEntryView(entries: .constant([]))
    }
}
