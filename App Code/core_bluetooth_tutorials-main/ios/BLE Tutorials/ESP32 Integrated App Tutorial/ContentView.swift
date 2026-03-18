import SwiftUI

struct ContentView: View {
    @State private var ble = BLEManager()

    private var connectionLabel: String {
        if ble.isScanning { return "Scanning…" }
        return ble.isConnected ? "Connected" : "Not connected"
    }

    private var connectionColor: Color {
        if ble.isScanning { return .orange }
        return ble.isConnected ? .green : .secondary
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Status card
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(connectionColor)
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(connectionLabel)
                                .font(.headline)
                            Text(ble.isConnected ? "Device connected" : "Select a device below")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Light Status")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(ble.statusText.isEmpty ? "—" : ble.statusText)
                                .font(.title3)
                                .fontWeight(.semibold)
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
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        ble.disconnect()
                    } label: {
                        Label("Disconnect", systemImage: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!ble.isConnected)
                }

                // Devices
                VStack(alignment: .leading, spacing: 8) {
                    Text("Devices")
                        .font(.headline)

                    if ble.devices.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.title2)
                                .foregroundStyle(.secondary)

                            Text(ble.isScanning ? "Searching…" : "Tap Scan to find your ESP32")
                                .font(.subheadline)
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
                                            .font(.body)
                                        Text("RSSI \(d.rssi)")
                                            .font(.caption)
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

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("ESP32 BLE Demo")
        }
    }
}
