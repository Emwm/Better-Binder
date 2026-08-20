//
//  HistoryView.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/19/26.
//

import SwiftUI
import Foundation
import Charts
import SwiftData

// A simple model for charting daily totals
private struct DayTotal: Identifiable {
    let id = UUID()
    let day: Date
    let totalSeconds: Int
}

struct HistoryView: View {
    @Environment(BindTimer.self) private var timer
    @Query(sort: \BindSession.startDate, order: .reverse) var bindSessionHistory: [BindSession] // load data into an array
    
    @State private var expandedDays: Set<Date> = [] // Keep expansion state per day
    @State private var scrollXPosition: Date?
    
    @State private var selectedDate: Date = Date()
    @State private var showingWeekPicker: Bool = false
    
    private var calendar: Calendar { Calendar.current }
    
    private var startOfWeek: Date {
        // Determine the start of week (Sunday) for the selectedDate
        var cal = calendar
        cal.firstWeekday = 1 // 1 = Sunday
        let startOfSelected = cal.startOfDay(for: selectedDate)
        let weekday = cal.component(.weekday, from: startOfSelected)
        let daysFromSunday = weekday - cal.firstWeekday
        let currentWeekSunday = cal.date(byAdding: .day, value: -daysFromSunday, to: startOfSelected) ?? startOfSelected
        return currentWeekSunday
    }
    
    private var endOfWeek: Date {
        calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.addingTimeInterval(86399) // Saturday 23:59:59
    }
    
    private var selectedWeekRange: ClosedRange<Date> { startOfWeek...endOfWeek }
    
    private var weekTotals: [DayTotal] {
        // Build totals for only the selected week, ensuring an entry per day (Sun-Sat)
        let sessionsInWeek = bindSessionHistory.filter { session in
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
        let grouped = Dictionary(grouping: bindSessionHistory) { session in
            calendar.startOfDay(for: session.startDate)
        }
        return grouped
            .map { (day: $0.key, sessions: $0.value.sorted { $0.startDate > $1.startDate }) }
            .sorted { $0.day > $1.day }
    }
    
    private var groupedByDaySortedForSelectedWeek: [(day: Date, sessions: [BindSession])] {
        let filtered = bindSessionHistory.filter { session in
            let day = calendar.startOfDay(for: session.startDate)
            return selectedWeekRange.contains(day)
        }
        let grouped = Dictionary(grouping: filtered) { session in
            calendar.startOfDay(for: session.startDate)
        }
        return grouped
            .map { (day: $0.key, sessions: $0.value.sorted { $0.startDate > $1.startDate }) }
            .sorted { $0.day > $1.day }
    }
    
    private var dayTotals: [DayTotal] {
        let grouped = Dictionary(grouping: bindSessionHistory) { session in
            calendar.startOfDay(for: session.startDate)
        }
        return grouped
            .map { day, sessions in
                DayTotal(day: day, totalSeconds: sessions.reduce(0) { $0 + $1.durationSeconds })
            }
            .sorted { $0.day < $1.day } // ascending for a left-to-right timeline
    }
    
    var body: some View {
            VStack{
                
                // Top Header Section ---------------------------------
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
                
                // Chart Section -------------------------------------
                
                // Label at top of chart (buttons and week selection)
                HStack {
                    Button {
                        selectedDate = calendar.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(startOfWeek.formatted(.dateTime.month(.abbreviated).day().year())) – \(endOfWeek.formatted(.dateTime.month(.abbreviated).day().year()))")
                            .font(.appSmallCaptionBold())
                        Text("\(startOfWeek.formatted(.dateTime.weekday(.wide))) - \(calendar.date(byAdding: .day, value: 6, to: startOfWeek)!.formatted(.dateTime.weekday(.wide)))")
                            .font(.appSmallCaption())
                    }
                    .onTapGesture { showingWeekPicker = true }
                    
                    Spacer()
                    
                    Button {
                        let nextWeek = calendar.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
                        if nextWeek <= Date() { // prevent going into future weeks
                            selectedDate = nextWeek
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                    .disabled({
                        let nextWeek = calendar.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
                        return nextWeek > Date()
                    }())
                }
                .padding(.horizontal)
                
                // Chart visual
                Chart(weekTotals) { item in
                    BarMark(
                        x: .value("Day", item.day, unit: .day),
                        y: .value("Total Seconds", item.totalSeconds)
                    )
                    .foregroundStyle(Color.colorCoral)
                    .cornerRadius(4)
                    .annotation(position: .top, alignment: .center) {
                        
                    }
                    
                    RuleMark(y: .value("8 Hours", timer.secondsBindLimit))
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
                .sheet(isPresented: $showingWeekPicker) {
                    VStack {
                        DatePicker("Select a week", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .padding()

                        Button("Done") { showingWeekPicker = false }
                            .buttonStyle(.borderedProminent)
                    }
                    .presentationDetents([.medium, .large])
                }
                
                // History List -----------------------------------
                List {
                    ForEach(groupedByDaySortedForSelectedWeek, id: \.day) { dayGroup in
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
    // 1. Create an in-memory container (clears every time the preview restarts)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, configurations: config)
    
    // 3. Initialize the manager with the mock context
    let mockManager = BindTimer(modelContext: container.mainContext)
    
    HistoryView()
        .environment(mockManager)
}
