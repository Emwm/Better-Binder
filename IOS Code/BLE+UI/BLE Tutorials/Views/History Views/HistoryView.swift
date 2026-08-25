import SwiftUI
import Foundation
import Charts
import SwiftData

struct HistoryView: View {
    
    enum Tab {
        case weekview
        case yearview
        case tableview
    }
    
    @State private var selectedTab: Tab = .weekview
    
    var body: some View {
        VStack(spacing: 0) {

            
            Picker("History View", selection: $selectedTab) {
                Text("Week")
                    .tag(Tab.weekview)
                
                Text("Year")
                    .tag(Tab.yearview)
                
                Text("Table")
                    .tag(Tab.tableview)
            }
            .pickerStyle(.segmented)
            .padding()
            
            
            switch selectedTab {
            case .weekview:
                WeekView()
                
            case .yearview:
                YearView()
                
            case .tableview:
                TableView()
            }
        }
    }
}

#Preview {
    // 1. Create an in-memory container (clears every time the preview restarts)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, DailyBindTotal.self, configurations: config)
    
    // 3. Initialize the manager with the mock context
    let mockManager = BindTimer(modelContext: container.mainContext)
    
    HistoryView()
        .environment(mockManager)
}
