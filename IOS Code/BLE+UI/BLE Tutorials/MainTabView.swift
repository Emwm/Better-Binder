//
//  MainTabView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-19.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
        
    @State private var selectedTab = 0
    
    //ble update observables
    @Environment(BLEManager.self) private var ble
    @Environment(BindManager.self) private var bsm
    @Environment(BindTimer.self) private var timer

    var body: some View {
        TabView(selection: $selectedTab){
            Tab("Today", systemImage:"chart.xyaxis.line", value: 0){
                TodayView()
            }
            
            Tab("Journal", systemImage: "book", value: 1){
                JournalView()
            }
            Tab("History", systemImage:"calendar", value: 2 ){
                HistoryView()
            }
            Tab("Settings", systemImage:"gear", value: 3){
                SettingsView()
            }
            
        }
        .font(.appSmallCaption())
        .tint(Color.colorDarkCoral)
        //global binding updates, important
        .onChange(of: ble.statusInt) { oldValue, newValue in
            bsm.setRawInt(for: newValue, timer: timer)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BindSession.self, DailyBindTotal.self, configurations: config)
    
    MainTabView()
        .environment(BLEManager.mock)
        .environment(BindTimer(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(BindManager())
}
