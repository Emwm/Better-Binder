//
//  DeleteTodayView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/8/26.
//

import SwiftUI
import SwiftData

struct DeleteTodayView: View {
    @Environment(BindTimer.self) private var timer
    
    // for all of today session delete warning
    @State private var showConfirmDelete = false
    
    @Query private var todaySessions: [BindSession]

    init() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        // The Predicate acts like a SQL "WHERE" clause
        let filter = #Predicate<BindSession> { session in
            session.startDate >= startOfToday && session.startDate < endOfToday
        }

        // Initialize the query with the filter
        _todaySessions = Query(filter: filter, sort: \.startDate, order: .reverse)
    }
    
    func deleteAllTodaySessions() {
        for session in todaySessions {
            timer.deleteBindSession(session)
        }
    }
    
    var body: some View {
        HStack {
            Text("Delete Today Data:")
                .font(.appBody())
            Button(role: .destructive) {
                showConfirmDelete = true
            } label: {
                Text("Delete Today")
            }
            .font(.appBody())
        }
        .smallPaddingBottom()
        .padding(.horizontal)
        .alert("Delete all of today’s sessions?", isPresented: $showConfirmDelete) {
            Button("Delete", role: .destructive) {
                deleteAllTodaySessions()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        Spacer()
    }
}
