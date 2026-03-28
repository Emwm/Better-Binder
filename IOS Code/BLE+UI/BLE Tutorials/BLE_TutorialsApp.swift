//
//  BLE_TutorialsApp.swift
//  BLE Tutorials
//
//  Created by Dante Ausonio on 10/13/25.
//

import SwiftUI

@main
struct BLE_TutorialsApp: App {
    @State private var ble = BLEManager()
    @State private var timer = BindTimer()
    //    init() {
    //        // Seed once on app launch to add simulated data
    //        timer.seedFakeHistory(days: 10, sessionsPerDay: 3, durationRange: 300...3600)
    //    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(ble)
                .environment(\.bindTimer, timer)
        }
    }
}
