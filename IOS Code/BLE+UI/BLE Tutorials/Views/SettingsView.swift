//
//  SettingsView.swift
//  BLE Tutorials
//
//  Created by LOGIN on 2026-03-19.
//

import SwiftUI

struct SettingsView: View {
    @Environment(BLEManager.self) private var ble
    @State private var autoReconnect = true
    
    var body: some View {
        NavigationStack{
            Form{
                Section(header: Text("Connection")) {
                    NavigationLink{
                        BLEControlView()
                        
                    } label: {
                        Label("ESP32 Setup", systemImage: "dot.radiowaves.leftandright")
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

#Preview {
    MainTabView()
        .environment(BLEManager())
}
