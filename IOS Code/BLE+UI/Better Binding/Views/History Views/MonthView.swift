//
//  TableView.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 8/25/26.
//

import SwiftUI
import SwiftData
import Foundation

private struct DaySummary: Identifiable {
    let id = UUID()
    let day: Date
    let totalSeconds: Int
    let mentalScores: [Int]
    let physicalScores: [Int]
}

struct MonthView: View {
    @State private var selectedMonth: Date = Calendar.current.startOfDay(for: Date())
    @State private var showingMonthPicker = false

    private var calendar: Calendar { Calendar.current }

    private var monthRange: Range<Date> {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let end = calendar.date(byAdding: DateComponents(month: 1), to: start)!
        return start..<end
    }

    @Query(sort: \DailyTotal.day, order: .forward) private var baseDailyTotals: [DailyTotal]
    @Query(sort: \JournalEntry.timestamp, order: .forward) private var baseJournalEntries: [JournalEntry]

    private var allDailyTotals: [DailyTotal] {
        baseDailyTotals.filter { $0.day >= monthRange.lowerBound && $0.day < monthRange.upperBound }
    }
    private var allJournalEntries: [JournalEntry] {
        baseJournalEntries.filter { $0.timestamp >= monthRange.lowerBound && $0.timestamp < monthRange.upperBound }
    }

    // Build summaries by day by merging DailyTotal and JournalEntry data
    private var summaries: [DaySummary] {
        // Map totals by normalized day
        let totalsByDay: [Date: Int] = Dictionary(
            uniqueKeysWithValues: allDailyTotals.map { (calendar.startOfDay(for: $0.day), $0.totalSeconds) }
        )

        // Group journal entries by day
        let groupedEntries = Dictionary(grouping: allJournalEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }

        // Union of all days present in either dataset
        let allDays = Set(totalsByDay.keys).union(groupedEntries.keys)
        let sortedDays = allDays.sorted()

        return sortedDays.map { day in
            let total = totalsByDay[day] ?? 0
            let entries = groupedEntries[day] ?? []
            let mental = entries.map { $0.mentalWellness }
            let physical = entries.map { $0.physicalWellness }
            return DaySummary(day: day, totalSeconds: total, mentalScores: mental, physicalScores: physical)
        }
    }

    private func timeString(_ seconds: Int) -> String {
        // Expect an extension elsewhere, but provide a fallback here to avoid dependency.
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        if hrs > 0 { return String(format: "%dh %dm %ds", hrs, mins, secs) }
        if mins > 0 { return String(format: "%dm %ds", mins, secs) }
        return String(format: "%ds", secs)
    }

    init(initialMonth: Date? = nil) {
        if let initialMonth {
            _selectedMonth = State(initialValue: initialMonth)
        }
    }

    var body: some View {
        // Top Header Section ---------------------------------
//        HStack{
//            Image("logo_solidOutline_coral")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 50, height: 50)
//            Text("Month View") // list view of each bind today
//                .font(.appHeader())
//                .foregroundStyle(Color.colorDarkCoral)
//        }
//        .padding(.top, 5)
        
        VStack(alignment: .leading) {
            HStack {
                Button {
                    if let prev = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
                        // Snap to first of month
                        if let start = calendar.date(from: calendar.dateComponents([.year, .month], from: prev)) {
                            selectedMonth = start
                        } else {
                            selectedMonth = prev
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                    .onTapGesture { showingMonthPicker = true }
                
                Spacer()
                
                Button {
                    if let next = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
                        // Prevent navigating into future months beyond current month
                        let today = Date()
                        let startOfNext = calendar.date(from: calendar.dateComponents([.year, .month], from: next)) ?? next
                        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
                        if startOfNext <= startOfCurrentMonth {
                            selectedMonth = startOfNext
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .sheet(isPresented: $showingMonthPicker) {
                VStack {
                    DatePicker(
                        "Select month",
                        selection: $selectedMonth,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .onChange(of: selectedMonth) { _, newValue in
                        if let start = calendar.date(from: calendar.dateComponents([.year, .month], from: newValue)) {
                            selectedMonth = start
                        }
                    }
                    
                    Button("Done") { showingMonthPicker = false }
                        .buttonStyle(.borderedProminent)
                }
                .presentationDetents([.medium, .large])
            }
            
            // Header row
            HStack(spacing: 0) {
                Text("Date")
                    .font(.appTableHeader())
                    .frame(minWidth: 70, maxWidth: .infinity, alignment: .center)

                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 1)

                VStack{
                    Text("Bind")
                        .font(.appTableHeader())
                    Text("Time")
                        .font(.appTableHeader())
                }
                .frame(width: 100, alignment: .center)

                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 1)

                VStack{
                    Text("Mental")
                        .font(.appTableHeader())
                    Text("Scores")
                        .font(.appTableHeader())
                }
                .frame(width: 75, alignment: .center)

                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 1)

                VStack{
                    Text("Physical")
                        .font(.appTableHeader())
                    Text("Scores")
                        .font(.appTableHeader())
                }
                .frame(width: 75, alignment: .center)
            }
            .frame(height: 70) // keep header compact
            .padding(.horizontal)
            .background(Color(.colorLightCoral))
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color(.separator)), alignment: .bottom)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(summaries) { summary in
                        HStack(alignment: .center, spacing: 0) {
                            // Column 1: Date
                            Text(summary.day.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(
                                    (summary.totalSeconds >= 8 * 3600) ||
                                    ((summary.mentalScores.min() ?? 10) < 5) ||
                                    ((summary.physicalScores.min() ?? 10) < 5)
                                    ? Color.colorDarkCoral : Color.primary
                                )
                                .frame(minWidth: 70, maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 5)
                                .font(.appTableBody())
                            
                            // Optional vertical divider
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(width: 1)
                            
                            // Column 2: Total time (wider)
                            Text(timeString(summary.totalSeconds))
                                .foregroundStyle(summary.totalSeconds >= 8 * 3600 ? Color.colorDarkCoral : Color.primary)
                                .frame(width: 100, alignment: .center)
                                .font(.appTableBody())
                            
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(width: 1)
                            
                            // Column 3: Mental
                            Text(summary.mentalScores.isEmpty ? "—" : summary.mentalScores.map(String.init).joined(separator: ", "))
                                .foregroundStyle((summary.mentalScores.min() ?? 10) < 5 ? Color.colorDarkCoral : Color.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(width: 75, alignment: .center)
                                .font(.appTableBody())
                            
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(width: 1)
                            
                            // Column 4: Physical
                            Text(summary.physicalScores.isEmpty ? "—" : summary.physicalScores.map(String.init).joined(separator: ", "))
                                .foregroundStyle((summary.physicalScores.min() ?? 10) < 5 ? Color.colorDarkCoral : Color.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(width: 75, alignment: .center)
                                .font(.appTableBody())
                        }
                        .background(Color(.systemBackground))
                        
                        // Horizontal row divider
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 1)
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, DailyTotal.self, JournalEntry.self, configurations: config)
    
    MonthView()
        .environment(BindTimer(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(BindManager())
}
