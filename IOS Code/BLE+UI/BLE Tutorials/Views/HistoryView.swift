//
//  HistoryView.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/19/26.
//

import SwiftUI
import Foundation
import Charts

// A simple model for charting daily totals
private struct DayTotal: Identifiable {
    let id = UUID()
    let day: Date
    let totalSeconds: Int
}

struct HistoryView: View {
    @Environment(\.bindTimer) private var timer
    
    @State private var expandedDays: Set<Date> = [] // Keep expansion state per day
    @State private var scrollXPosition: Date?

    @State private var weekOffset: Int = 0 // 0 = current week, -1 = previous week, etc.

    private var calendar: Calendar { Calendar.current }

    private var startOfWeek: Date {
        // Determine the start of week (Sunday) for today shifted by weekOffset
        var cal = calendar
        cal.firstWeekday = 1 // 1 = Sunday
        let today = Date()
        let startOfToday = cal.startOfDay(for: today)
        let weekday = cal.component(.weekday, from: startOfToday)
        // Move back to Sunday of current week
        let daysFromSunday = weekday - cal.firstWeekday
        let currentWeekSunday = cal.date(byAdding: .day, value: -daysFromSunday, to: startOfToday) ?? startOfToday
        // Apply week offset
        return cal.date(byAdding: .day, value: weekOffset * 7, to: currentWeekSunday) ?? currentWeekSunday
    }

    private var endOfWeek: Date {
        calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.addingTimeInterval(86399) // Saturday 23:59:59
    }

    private var selectedWeekRange: ClosedRange<Date> { startOfWeek...endOfWeek }

    private var weekTotals: [DayTotal] {
        // Build totals for only the selected week, ensuring an entry per day (Sun-Sat)
        let sessionsInWeek = timer.bindSessionHistory.filter { session in
            let day = calendar.startOfDay(for: session.startDate)
            return selectedWeekRange.contains(day)
        }
        let grouped = Dictionary(grouping: sessionsInWeek) { session in
            calendar.startOfDay(for: session.startDate)
        }
        // Create an array with all seven days to avoid gaps
        var days: [DayTotal] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let total = grouped[date]?.reduce(0) { $0 + $1.durationSeconds } ?? 0
                days.append(DayTotal(day: date, totalSeconds: total))
            }
        }
        return days
    }

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
    
    // start of View --------------------------------------------
    
    var body: some View {
        VStack{
            // Top Header ----------------------
            HStack{
                Image("logo_solidOutline_coral")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("History") // list view of each bind today
                    .font(.appHeader())
                    .foregroundStyle(Color.colorDarkCoral)
            }
            .padding(.top, 10)
            
            // Daily totals chart ----------------------------------
            // buttons and week label at top of chart------
            HStack {
                Button {
                    weekOffset -= 1
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(spacing: 2) {
                    Text("Week of \(startOfWeek.formatted(.dateTime.month(.abbreviated).day().year()))")
                        .font(.appSmallCaptionBold())
                    Text("\(startOfWeek.formatted(.dateTime.weekday(.wide))) - \(calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.formatted(.dateTime.weekday(.wide)))")
                        .font(.appSmallCaption())
                }

                Spacer()

                Button {
                    if weekOffset < 0 { // prevent going into future weeks
                        weekOffset += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
                .disabled(weekOffset >= 0)
            }
            .padding(.horizontal)

            // chart visual -------------
            Chart(weekTotals) { item in
                BarMark(
                    x: .value("Day", item.day, unit: .day),
                    y: .value("Total Seconds", item.totalSeconds)
                )
                .foregroundStyle(Color.colorCoral)
                .cornerRadius(4)
                .annotation(position: .top, alignment: .center) {
                    
                }

                RuleMark(y: .value("8 Hours", 8 * 60 * 60))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 6]))
                    .foregroundStyle(Color.colorDarkCoral)
            }
            .chartPlotStyle { plot in
                plot
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .chartXScale(domain: selectedWeekRange)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.month(.abbreviated).day()))
                        }
                    }
                }
            }
            .chartYAxis {
                // 0h through 12h in 2-hour steps (in seconds)
                let ticks: [Double] = stride(from: 0, through: Double(12 * 3600), by: Double(2 * 3600)).map { $0 }
                AxisMarks(values: ticks) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let seconds = value.as(Double.self) {
                            let hours = Int(seconds) / 3600
                            Text("\(hours)h")
                        }
                    }
                }
            }
            .chartYScale(type: .linear)
            .frame(height: 220)
            .padding(.horizontal, 25)
            
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
                                                .font(.appBody())
                                                .frame(width: 150, alignment: .leading) // fixes width of the column

                                            Text("Duration: \(history.durationSeconds.asTimestamp())")
                                                .font(.appBody())
                                                .frame(width: 180, alignment: .leading)
                                            
                                            Spacer()
                                    }
                                }
                            },
                            label: {
                                // Shows the headers in the list, the date and total time for each date
                                VStack(alignment: .leading) {
                                    Text(dayGroup.day.formatted(date: .abbreviated, time: .omitted))
                                        .font(.appBodyBold())
                                        .smallPaddingBottom()
                                        
                                    HStack{
                                        Text("Total Duration: \(totalSeconds.asTimestamp())")
                                            .font(.appBody())
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
#Preview {
    HistoryView()
}

