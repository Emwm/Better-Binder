//
//  MainTabView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-19.
//

import SwiftUI

struct MainTabView: View {
        
    @State private var selectedTab = 1
    
    //ble update observables
    @Environment(BLEManager.self) private var ble
    @Environment(BindManager.self) private var bsm
    @Environment(\.bindTimer) private var timer

    var body: some View {
        TabView(selection: $selectedTab){
            Tab("History", systemImage:"calendar", value: 0 ){
                HistoryView()
            }
            Tab("Today", systemImage:"chart.xyaxis.line", value: 1){
                TodayView()
            }
            Tab("Settings", systemImage:"gear", value: 2){
                SettingsView()
            }
            
        }
        //global binding updates, important
        .onChange(of: ble.statusInt) { oldValue, newValue in
            bsm.setRawInt(for: newValue, timer: timer)
        }
    }
}

#Preview {
    MainTabView()
        .environment(BLEManager.mock)
        .environment(BindTimer())
        .environment(BindManager())
}
