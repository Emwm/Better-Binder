//
//  JournalHistoryView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-29.
//

import Foundation
import SwiftUI

struct JournalListView: View {
    @State private var allEntries: [JournalEntry] = []
    @State private var isShowingEditor = false

    var body: some View {
        NavigationStack {
            List(allEntries) { entry in
                VStack{
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.text)
                        .lineLimit(3) // Show a preview
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                Button(action: { isShowingEditor = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isShowingEditor) {
                NewEntryView(entries: $allEntries)
            }
        }
    }
}
#Preview{
    JournalListView()
}
