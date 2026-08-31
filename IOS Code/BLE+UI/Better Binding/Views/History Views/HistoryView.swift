import SwiftUI
import Foundation
import Charts
import SwiftData

struct HistoryView: View {
    
    enum Tab {
        case weekview
        case yearview
        case monthview
    }
    
    @State private var selectedTab: Tab = .weekview
    
    private func tabButton(_ title: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(selectedTab == tab ? .appBodyBold() : .appBody())
                .foregroundStyle(selectedTab == tab ? .white : .primary)
                .frame(maxWidth: 80)
                .padding(.vertical, 5)
                .background(
                    selectedTab == tab ? Color.colorCoral : Color.colorLightCoral
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    var body: some View {
        VStack {
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
            
            HStack(spacing: 10) {
                tabButton("Week", tab: .weekview)
                tabButton("Month", tab: .monthview)
                tabButton("Year", tab: .yearview)
            }
            .mediumPaddingBottom()
            
            
            
//            Picker("History View", selection: $selectedTab) {
//                Text("Week")
//                    .tag(Tab.weekview)
//                
//                Text("Month")
//                    .tag(Tab.monthview)
//                
//                Text("Year")
//                    .tag(Tab.yearview)
//            }
//            .pickerStyle(.segmented)
//            .font(.appBodyBold())
//            .padding()
//            
            switch selectedTab {
            case .weekview:
                WeekView()
                
            case .monthview:
                MonthView()
                
            case .yearview:
                YearView()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, DailyTotal.self, JournalEntry.self, configurations: config)
    
    HistoryView()
        .environment(BindTimer(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(BindManager())
}
