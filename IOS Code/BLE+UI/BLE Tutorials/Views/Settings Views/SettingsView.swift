//
//  SettingsView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-19.
//

import SwiftUI

struct SettingsView: View {
    @State private var autoReconnect = true
    
    var body: some View {
        VStack{
            HStack{
                Image("bBird")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("Settings") // list view of each bind today
                    .font(Font.largeTitle.bold())
                    .bold()
            }
            .padding(.top, 10)
            
            NavigationStack{
                Form{
                    Section(header: Text("Connection")) {
                        NavigationLink{
                            BLEControlView()
                        } label: {
                            Label("ESP32 Setup", systemImage: "badge.plus.radiowaves.right")
                        }
                    }
                    Section(header: Text("Notifications")) {
                        NavigationLink{
                            NotificationControlView()
                        } label: {
                            Label("Notification Setup", systemImage: "bell.badge.fill")
                        }
                    }
                    Section(header: Text("Testing")) {
                        NavigationLink{
                            TestTimerView()
                        } label: {
                            Label("Test Timer", systemImage: "timer.circle.fill")
                        }
                        
                    }
                    Section(header: Text("Calibration")) {
                        NavigationLink{
                            CalibrationView()
                        } label: {
                            Label("Calibration", systemImage: "timer.circle.fill")
                        }
                        
                    }
                    /*Section(header: Text("Connection"), footer: Text("Automatically tries to find your ESP32 on launch.")){
                        Button("Setup Connection"){
                            //BLEControlView() fix with proper int control
                        }
                    }*/
                }
            }
            
        }
    }
}

//#Preview {
//    MainTabView()
//        .environment(BLEManager.mock)
//}
