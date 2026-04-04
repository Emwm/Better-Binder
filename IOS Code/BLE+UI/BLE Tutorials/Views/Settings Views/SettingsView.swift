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
                Image("logo_solidFill_blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("Settings") // list view of each bind today
                    .font(.appHeader())
                    .bold()
            }
            .padding(.top, 10)
            
            NavigationStack{
                Form{
                    Section(header: Text("Device")) {
                        NavigationLink{
                            BLEControlView()
                        } label: {
                            Label("Device Connection", systemImage: "badge.plus.radiowaves.right")
                        }
                        .font(.appBody())
                        NavigationLink{
                            CalibrationView()
                        } label: {
                            Label("Compression Calibration", systemImage: "slider.horizontal.3")
                        }
                        .font(.appBody())
                    }
                    Section(header: Text("Notifications")) {
                        NavigationLink{
                            NotificationControlView()
                        } label: {
                            Label("Notification Setup", systemImage: "bell.badge.fill")
                        }
                        .font(.appBody())
                    }
                    Section(header: Text("Testing")) {
                        NavigationLink{
                            TestTimerView()
                        } label: {
                            Label("Test Timer", systemImage: "timer.circle.fill")
                        }
                        .font(.appBody())
                        
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
