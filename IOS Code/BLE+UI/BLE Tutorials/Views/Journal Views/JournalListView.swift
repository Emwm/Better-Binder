//
//  JournalListView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 3/30/26.
//

import Foundation
import SwiftUI

struct JournalListView: View {
    @State private var allEntries: [JournalEntry] = []
    @State private var isShowingEditor = false

    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Image("bwBird")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text("Journal")
                        .font(Font.largeTitle.bold())
                    Image("bwBird")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .scaleEffect(x: -1, y: 1)
                }
                Text("Create a journal entry to reflect on how you felt binding today.")
                    .font(Font.body)
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
            }
            List(allEntries) { entry in
                VStack{
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.text)
                        .lineLimit(3) // Show a preview
                }
            }
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
