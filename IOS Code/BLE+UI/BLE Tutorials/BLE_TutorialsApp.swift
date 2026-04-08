//
//  BLE_TutorialsApp.swift
//  BLE Tutorials
//
//  Created by Dante Ausonio on 10/13/25.
//

import SwiftUI
import SwiftData

@main
struct BLE_TutorialsApp: App {
    let container: ModelContainer
    
    init() {
        container = try! ModelContainer(for: BindSession.self) // initialize persistant storage
    }
    
    @State private var ble = BLEManager()
    @State private var bsm = BindManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(ble)
                .environment(BindTimer(modelContext: container.mainContext))
                .environment(bsm)
        }
        .modelContainer(container) // sets up database
    }
}
