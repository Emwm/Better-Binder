//
//  PrototypeAApp.swift
//  PrototypeA
//
//  Created by Reese Brogden on 3/1/26.
//

// This file is the apps entry point

import SwiftUI

@main // marks this file as the entry point when running app
struct PrototypeAApp: App {
    @State private var timer = BindTimer()

//    init() {
//        // Seed once on app launch to add simulated data
//        timer.seedFakeHistory(days: 10, sessionsPerDay: 3, durationRange: 300...3600)
//    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.bindTimer, timer)
        }
    }
}
