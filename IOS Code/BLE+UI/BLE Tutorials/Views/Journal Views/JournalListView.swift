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
                    Text("Journal")
                        .font(.appHeader())
                        .foregroundColor(.colorDarkCoral)
                    Image("logo_solidOutline_coral")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .scaleEffect(x: -1, y: 1)
                }
                Text("Create a journal entry to reflect on how you felt binding today.")
                    .font(.appBody())
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
            }
            List(allEntries) { entry in
                VStack(alignment: .leading){
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.appBodyBold())
                        .smallPaddingBottom()
                    
                    Text(entry.text)
                        .lineLimit(3) // Show a preview
                        .font(.appBody())
                }
                HStack {
                    Text("Physical Discomfort: \(Int(entry.physicalWellness))/10").font(.appSmallCaption())
                    Text("Wellbeing: \(Int(entry.mentalWellness))/10").font(.appSmallCaption())
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
