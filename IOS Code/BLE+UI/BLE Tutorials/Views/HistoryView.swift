//
//  HistoryView.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/19/26.
//

import SwiftUI
import Foundation
import Charts

// formats our seconds variables into hh, mm, ss
private func _formatSeconds(_ seconds:Int) -> String {
    if seconds <= 0 {
        return "00:00:00"
    }
    let hh: Int = seconds / 3600
    let mm: Int = (seconds % 3600) / 60
    let ss: Int = seconds % 60
    return String(format: "%02d:%02d:%02d", hh, mm, ss)
}

// A simple model for charting daily totals
private struct DayTotal: Identifiable {
    let id = UUID()
    let day: Date
    let totalSeconds: Int
}

struct HistoryView: View {
    @Environment(\.bindTimer) private var timer
    // public varaibles in BindTimer class -> secondsPassedToday, secondsPassedTodayString, secondsLeftToday, secondsLeftTodayString, fractionPassedToday, fractionLeftToday, bindSessionHistory, bindTimerState, secondsPassedThisBind
    
    // Helpers to format history view--------------------
    // Keep expansion state per day (keyed by Date at start of day)
    @State private var expandedDays: Set<Date> = []
    @State private var scrollXPosition: Date?

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
    
    private var dayTotals: [DayTotal] {
        let grouped = Dictionary(grouping: timer.bindSessionHistory) { session in
            calendar.startOfDay(for: session.startDate)
        }
        return grouped
            .map { day, sessions in
                DayTotal(day: day, totalSeconds: sessions.reduce(0) { $0 + $1.durationSeconds })
            }
            .sorted { $0.day < $1.day } // ascending for a left-to-right timeline
    }
    
    // Compute visible domain that ends at the latest day
    private var visibleXDomain: ClosedRange<Date>? {
        guard let last = dayTotals.last?.day else { return nil }
        let length: TimeInterval = 604800 // 7 days
        let start = last.addingTimeInterval(-length)
        return start...last
    }
    
    //--------------------------------------------
    
    var body: some View {
        VStack{
            HStack{
                Image("bBird")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("History") // list view of each bind today
                    .font(Font.largeTitle.bold())
                    .bold()
            }
            .padding(.top, 10)
            
            // Daily totals chart ----------------
            Chart(dayTotals) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Total Seconds", item.totalSeconds)
                )
                .foregroundStyle(.blue)
                .cornerRadius(4)
                .annotation(position: .top, alignment: .center) {
                    
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.month(.abbreviated).day()))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let seconds = value.as(Int.self) {
                            // Show minutes for readability
                            let hours = seconds / (60*60)
                            Text("\(hours)hours")
                        }
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 604800) //seconds in a week lol
            .frame(height: 220)
            .padding(.horizontal)
            .defaultScrollAnchor(.trailing) //set the rightmost side as default scroll position
            
            // History List ---------------------------
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
                                        Text("Start: \(history.startDate.formatted(date: .omitted, time: .shortened))")
                                        Spacer()
                                        Text("Duration: \(_formatSeconds(history.durationSeconds))")
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
                                        Text("Total Duration: \(_formatSeconds(totalSeconds))")
                                            .font(.body)
                                            .monospacedDigit()
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
//    let previewTimer = BindTimer() // or whatever your type is
//    previewTimer.seedFakeHistory(days: 10, sessionsPerDay: 3, durationRange: 300...3600)
//
//    return HistoryView()
//        .environment(\.bindTimer, previewTimer)
    HistoryView()
}
