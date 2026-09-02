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
                    
                    //dont love this location but idk what to do
                    InfoButton(title: "Journal Page Help", tint: .colorDarkCoral) {
                        VStack {
                            Text("Page Overview:")
                                .font(.appBodyBold())
                            Text("Use this page to keep track of how you've been feeling after a day of binding with a quick wellness check in")
                                .font(.appBody())
                                .mediumPaddingBottom()
                        
                            Text("Page Features:")
                                .font(.appBodyBold())
                                .smallPaddingBottom()
                            // manual list
                            VStack(alignment: .leading) {
                                Label("Create a new journal entry with the + sign at the top right ", systemImage: "1.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Label("Previous journal entries show up chronologically below, with a quick overview", systemImage: "2.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                Label("Click on any entry for a more in depth view of that day", systemImage: "3.circle")
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .font(.appSmallCaption())
                            .mediumPaddingBottom()
                            
                            Text("Tips:")
                                .font(.appBodyBold())
                                .smallPaddingBottom()
                            // manual list
                            VStack(alignment: .leading) {
                                Label("Journal entries are also tracked in the history view, check out that page for longer term trends", systemImage: "1.circle") // might want to replace with a better img
                                    .smallPaddingBottom()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            .font(.appSmallCaption())
                            .mediumPaddingBottom()
                    }
                }
                    Image("logo_solidOutline_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .scaleEffect(x: -1, y: 1)
                        .padding(.horizontal, 5)
                    
                }
                .padding(.horizontal)
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
