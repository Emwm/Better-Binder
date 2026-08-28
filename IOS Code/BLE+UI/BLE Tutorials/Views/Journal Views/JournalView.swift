//
//  JournalView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/30/26.
//

import Foundation
import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \JournalEntry.timestamp, order: .reverse)
    private var allEntries: [JournalEntry]
    @State private var isShowingEditor = false

    var body: some View {

        NavigationStack {
            VStack{
                HStack{
                    Image("logo_solidOutline_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.horizontal, 5)
                    Text("Journal")
                        .font(.appHeader())
                        .foregroundColor(.colorDarkCoral)
                    Image("logo_solidOutline_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .scaleEffect(x: -1, y: 1)
                        .padding(.horizontal, 5)
                }
                .padding(.horizontal)
                .mediumPaddingBottom()
                
                NavigationLink {
                    JournalVisualHistoryView()
                } label: {
                    HStack {
                        Text("Visual History")
                            .font(.appBodyBold())
                        Image(systemName: "chevron.right")
                    }
                }
                .mediumPaddingBottom()
                
                Text("Previous Entries:")
                    .font(.appBodyBold())
            }
            List(allEntries) { entry in
                NavigationLink {
                    SavedJournalEntryView(entry: entry)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.timestamp.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.shortened))
                            .font(.appBody())
                        Text("Physical: \(Int(entry.physicalWellness)) / 10   |   Emotional: \(Int(entry.mentalWellness)) / 10")
                            .font(.appSmallCaption())
                            .foregroundColor(.secondary)
                    }
                    .smallPaddingBottom()
                }
            }
            .toolbar {
                Button(action: { isShowingEditor = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isShowingEditor) {
                NewEntryView(entries: .constant([]))
            }
        }
    }
}
#Preview{
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: JournalEntry.self, configurations: config)
        return JournalView()
            .modelContainer(container)
    } catch {
        return JournalView()
    }
}
