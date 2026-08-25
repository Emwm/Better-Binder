import SwiftUI
import Foundation
import SwiftData

struct SavedJournalEntryView: View {
    let entry: JournalEntry
    
    @Query private var dailyTotal: [DailyBindTotal]

    init(entry: JournalEntry) {
        self.entry = entry

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: entry.date)

        let filter = #Predicate<DailyBindTotal> { total in
            total.day == startOfDay
        }
        _dailyTotal = Query(filter: filter)
    }

    private var totalSecondsForDay: Int {
        dailyTotal.first?.totalSeconds ?? 0
    }
    private var totalTimeString: String {
        totalSecondsForDay.asTimestamp()
    }

    var body: some View {
        ScrollView {
            VStack {
                // Header
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.appSubHeader())
                    .mediumPaddingBottom()
                    .mediumPaddingTop()
                
                ZStack(alignment: .leading){
                    // Background rectangle
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.colorLightBlue))
                    
                    VStack(alignment: .leading){
                        // Scores
                        Text("Physical Wellness:  \(Int(entry.physicalWellness)) / 10")
                            .font(.appBody())
                            .mediumPaddingTop()
                            .smallPaddingBottom()
                        Text("Emotional Wellness:  \(Int(entry.mentalWellness)) / 10")
                            .font(.appBody())
                            .mediumPaddingBottom()
                    }
                    .padding(.leading, 20)
                }
                .padding(.horizontal, 20)
                .smallPaddingBottom()
                
                ZStack(alignment: .leading){
                    // Background rectangle
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.colorLightCoral))
                    
                    VStack(alignment: .leading){
                        // Total time binding on this date
                        Text("Total Time Binding:  \(totalTimeString)")
                            .font(.appBody())
                            .mediumPaddingBottom()
                            .mediumPaddingTop()
                    }
                    .padding(.leading, 20)
                }
                .padding(.horizontal, 20)
                .smallPaddingBottom()

                // Notes
                Text("Journal Notes:")
                    .font(.appBody())
                    .smallPaddingBottom()
                Text(entry.text.isEmpty ? "None" : entry.text)
                    .font(.appBody())

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SavedJournalEntryView(entry: JournalEntry(text: "Sample notes...", date: .now, physicalWellness: 7, mentalWellness: 6))
}
