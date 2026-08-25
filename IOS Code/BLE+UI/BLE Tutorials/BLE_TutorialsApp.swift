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
    
    @State private var ble: BLEManager
    @State private var bsm: BindManager
    @State private var bindTimer: BindTimer
    
    init() {
        let safeContainer = try! ModelContainer(for: BindSession.self, DailyBindTotal.self)
        self.container = safeContainer
        
        //setup managers
        let initalizedTimer = BindTimer(modelContext: safeContainer.mainContext)
        let initalizedBSM = BindManager()
        let initalizedBLE = BLEManager()
        
        //let them communicate in the background
        initalizedBLE.onNewDataReceived = { newValue in
            initalizedBSM.setRawInt(for: newValue, timer: initalizedTimer)
        }
        
        _bindTimer = State(initialValue: initalizedTimer)
        _bsm = State(initialValue: initalizedBSM)
        _ble = State(initialValue: initalizedBLE)
    }
    

    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(ble)
                .environment(bindTimer)
                .environment(bsm)
        }
        .modelContainer(container) // sets up database
    }
}
