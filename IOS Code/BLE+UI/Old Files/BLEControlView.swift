import SwiftUI

struct BLEControlView: View {
    @Environment(BLEManager.self) private var ble
    
    private var connectionLabel: String {
        if ble.isScanning { return "Scanning…" }
        return ble.isConnected ? "Connected" : "Not connected"
    }
    
    private var connectionColor: Color {
        if ble.isScanning { return .colorCoral }
        return ble.isConnected ? .colorGreen : .secondary
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 16) {
                Text("Device Status")
                    .font(.appSubHeader())
                // Status card
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(connectionColor)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(connectionLabel)
                                .font(.appBodyBold())
                            Text(ble.isConnected ? "Device connected" : "Select a device below")
                                .font(.appSmallCaption())
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sensor Value")
                                .font(.appBodyBold())
                            Text(ble.statusText.isEmpty ? "—" : ble.statusText)
                                .font(.appBody())
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        Spacer()
                    }
                }
                .padding(14)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Controls
                HStack(spacing: 10) {
                    Button {
                        ble.isScanning ? ble.stopScan() : ble.startScan()
                    } label: {
                        Label(ble.isScanning ? "Stop" : "Scan", systemImage: ble.isScanning ? "stop.fill" : "dot.radiowaves.left.and.right")
                            .frame(maxWidth: .infinity)
                            .font(.appBody())
                    }
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive) {
                        ble.disconnect()
                    } label: {
                        Label("Disconnect", systemImage: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .font(.appBody())
                    }
                    .buttonStyle(.bordered)
                    .disabled(!ble.isConnected)
                }
                
                // Devices
                VStack(alignment: .leading, spacing: 8) {
                    Text("Devices")
                        .font(.appBodyBold())
                    
                    if ble.devices.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            
                            Text(ble.isScanning ? "Searching…" : "Tap Scan to find your device")
                                .font(.appSmallCaption())
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .background(.quaternary.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        List(ble.devices) { d in
                            Button {
                                ble.connect(to: d)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(d.name)
                                            .font(.appBody())
                                        Text("RSSI \(d.rssi)")
                                            .font(.appSmallCaption())
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                        }
                        .listStyle(.insetGrouped)
                        .frame(height: 260)
                    }
                }
                /*
                 // LED controls
                 HStack(spacing: 10) {
                 Button {
                 ble.send("LED:1")
                 } label: {
                 Label("LED ON", systemImage: "lightbulb.fill")
                 .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.borderedProminent)
                 .disabled(!ble.isConnected)
                 
                 Button {
                 ble.send("LED:0")
                 } label: {
                 Label("LED OFF", systemImage: "lightbulb.slash.fill")
                 .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.bordered)
                 .disabled(!ble.isConnected)
                 }
                 */
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
}
#Preview {
    BLEControlView()
        .environment(BLEManager.mock)
}
