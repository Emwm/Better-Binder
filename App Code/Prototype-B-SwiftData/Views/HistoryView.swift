//
//  HistoryView.swift
//  Prototype-B-SwiftData
//
//  Created by Reese Brogden on 3/16/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \BindSessionModel.startDate, order: .reverse) // @query is a property wrapper that fetches and observes objects from our bind session model
    private var sessions: [BindSessionModel] // storage for the query results in this view
    @Environment(\.modelContext) private var historyViewContext // allows this view to access the model context and make changes, this is good so that the user driven effects on the data (like here the delete) can be saved

    var body: some View {
        List {
            ForEach(sessions) { session in
                VStack(alignment: .leading) {
                    Text(session.startDate.formatted())
                    Text("\(session.durationSeconds) seconds")
                }
            }
            .onDelete { indexSet in //enables user based deleting from the list view
                for index in indexSet {
                    let session = sessions[index]
                    delete(session)
                }
            }
        }
    }

    // in future should maybe only allow in the today history view versus the total history view
    private func delete(_ session: BindSessionModel) {
        historyViewContext.delete(session)
        do {
            try historyViewContext.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}
