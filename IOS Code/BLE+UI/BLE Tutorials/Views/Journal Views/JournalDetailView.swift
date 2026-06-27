import SwiftUI
import Foundation

struct JournalDetailView: View {
    let entry: JournalEntry

    var body: some View {
        ScrollView {
            // I CANNOT FIGURE OUT WHY UI IS SO FAR TO THE RIGHT, bro
            VStack(alignment: .leading) {
                // Header
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.appSubHeader())
                    .mediumPaddingBottom()
                    .mediumPaddingTop()

                // Scores
                Text("Physical Wellness: \(Int(entry.physicalWellness)) / 10")
                    .font(.appBody())
                    .smallPaddingBottom()
                Text("Emotional Wellness: \(Int(entry.mentalWellness)) / 10")
                    .font(.appBody())
                    .mediumPaddingBottom()
                
                // Want to add total time binding today

                // Notes
                Text("Notes:")
                    .font(.appBody())
                Text(entry.text.isEmpty ? "None" : entry.text)
                    .font(.appBody())

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    JournalDetailView(entry: JournalEntry(text: "Sample notes...", date: .now, physicalWellness: 7, mentalWellness: 6))
}
