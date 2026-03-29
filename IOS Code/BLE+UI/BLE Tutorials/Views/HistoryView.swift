//
//  HistoryView.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/19/26.
//

import SwiftUI
import Foundation

// formats our seconds variables into hh, mm, ss
private func _formatSeconds(_ seconds:Int) -> String {
    if seconds <= 0 {
        return "00:00:00"
    }
    let hh: Int = seconds / 3600
    let mm: Int = (seconds % 3600) / 60
    let ss: Int = seconds % 60
    return String(format: "%02d:%02d.%02ds", hh, mm, ss)
}

struct HistoryView: View {
    @Environment(\.bindTimer) private var timer
    // public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
    
    // Helpers to format history view--------------------
    // Keep expansion state per day (keyed by Date at start of day)
    @State private var expandedDays: Set<Date> = []

    private var calendar: Calendar { Calendar.current }

    // Replace 'BindSession' with your actual type if different
    private var groupedByDaySorted: [(day: Date, sessions: [BindSession])] {
        let grouped = Dictionary(grouping: timer.bindSessionHistory) { session in
            calendar.startOfDay(for: session.startDate)
        }
        return grouped
            .map { (day: $0.key, sessions: $0.value.sorted { $0.startDate > $1.startDate }) }
            .sorted { $0.day > $1.day }
    }
    //--------------------------------------------
    
    var body: some View {
        VStack{
            Text("Total History of Binds:") // list view of each bind today
                .font(.system(size: 20))
                .bold()
                .padding(.top, 10)
            
            List {
                ForEach(groupedByDaySorted, id: \.day) { dayGroup in
                    let totalSeconds = dayGroup.sessions.reduce(0) { $0 + $1.durationSeconds }
                    let isExpanded = Binding(
                        get: { expandedDays.contains(dayGroup.day) },
                        set: { newValue in
                            if newValue {
                                expandedDays.insert(dayGroup.day)
                            } else {
                                expandedDays.remove(dayGroup.day)
                            }
                        }
                    )
                    Section {
                        DisclosureGroup(
                            isExpanded: isExpanded,
                            content: {
                                // subgroup of the list that shows each days values
                                ForEach(dayGroup.sessions) { history in
                                    HStack {
                                        Text(" \(history.startDate.formatted(date: .omitted, time: .shortened))")
                                        Spacer()
                                        Text(" \(_formatSeconds(history.durationSeconds))")
                                            .monospacedDigit()
                                    }
                                }
                            },
                            label: {
                                // Shows the headers in the list, the date and total time for each date
                                HStack {
                                    Text(dayGroup.day.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 17))
                                        
                                    Spacer()
                                    HStack{
                                        Text("Total Time:")
                                            .font(.system(size: 17))
                                            .monospacedDigit()
                                            
                                        Text("\(_formatSeconds(totalSeconds))")
                                            .font(.body)
                                            .monospacedDigit()
                                            .bold()
                                    }
                                }
                            }
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
        }
    }
}
#Preview { // this is for formatting
    let previewTimer = BindTimer() // or whatever your type is
    previewTimer.seedFakeHistory(days: 10, sessionsPerDay: 3, durationRange: 300...3600)

    return HistoryView()
        .environment(\.bindTimer, previewTimer)
}
