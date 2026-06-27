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
                    WellnessVisualHistoryView()
                } label: {
                    HStack {
                        Text("Visual History")
                            .font(.appBody())
                        Image(systemName: "chevron.right")
                    }
                }
                .mediumPaddingBottom()
                
                Text("List of Previous Entries:")
                    .font(.appBody())
            }
            List(allEntries.sorted(by: { $0.date > $1.date })) { entry in
                NavigationLink {
                    JournalDetailView(entry: entry)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
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
                NewEntryView(entries: $allEntries)
            }
        }
    }
}
#Preview{
    JournalListView()
}
