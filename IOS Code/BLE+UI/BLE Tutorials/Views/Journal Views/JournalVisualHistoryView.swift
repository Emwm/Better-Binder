import SwiftUI
import Foundation

struct JournalVisualHistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wellness Visual History")
                .font(.appSubHeader())
                .foregroundColor(.colorDarkCoral)
                .smallPaddingBottom()

            Text("Coming soon: charts and trends for your physical and emotional wellness scores.")
                .font(.appBody())
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    JournalVisualHistoryView()
}
