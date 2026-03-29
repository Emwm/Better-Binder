//
//  MainTabView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-19.
//

import SwiftUI

struct MainTabView: View {
        
    @State private var selectedTab = 1
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
    }
}

#Preview {
    MainTabView()
        .environment(BLEManager.mock)
        .environment(BindTimer())
}
