import CoreBluetooth
import Observation
internal import Combine


// MARK: - UUIDs (keep constant across series)
enum BLEIDs {
    static let service = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let cmd     = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static let status  = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
}



// MARK: - Minimal observable manager
@Observable
final class BLEManager: NSObject, @unchecked Sendable {
    // UI-facing state
    var isBluetoothOn = false
    var isScanning = false
    var isConnected = false
    var devices: [Device] = []
    var statusText: String = "---"
    var statusInt: Double = 0

    struct Device: Identifiable, Hashable {
        let id: UUID
        let name: String
        let rssi: Int
    }

    // CoreBluetooth handles
    private var central: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var cmdChar: CBCharacteristic?
    private var statusChar: CBCharacteristic?

    // Single Initializer with a default value
    init(startCentral: Bool = true) {
            super.init()
            
            // Detect if Xcode is running this for a preview
            let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            
            // Only start the hardware stack if explicitly requested AND not in a preview
            if startCentral && !isPreview {
                self.central = CBCentralManager(delegate: self, queue: nil)
            }
        }

    // MARK: - Safe Public API
    func startScan() {
        // Use optional chaining to prevent crashes if central is nil
        guard isBluetoothOn, let central = central else { return }
        devices.removeAll()
        isScanning = true
        central.scanForPeripherals(withServices: [BLEIDs.service], options: nil)
    }

    func stopScan() {
        isScanning = false
        central?.stopScan()
    }

    func connect(to device: Device) {
        guard let central = central,
              let p = central.retrievePeripherals(withIdentifiers: [device.id]).first else { return }
        stopScan()
        peripheral = p
        p.delegate = self
        central.connect(p, options: nil)
    }

    func disconnect() {
        guard let p = peripheral else { return }
        central?.cancelPeripheralConnection(p)
    }

    func send(_ text: String) {
        guard let p = peripheral, let c = cmdChar else { return }
        guard let data = text.data(using: .utf8) else { return }
        p.writeValue(data, for: c, type: .withoutResponse)
    }
}






// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothOn = (central.state == .poweredOn)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let name = peripheral.name
            ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? "Unknown"

        let d = Device(id: peripheral.identifier, name: name, rssi: RSSI.intValue)
        if !devices.contains(d) { devices.append(d) }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices([BLEIDs.service])
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        isConnected = false
        cmdChar = nil
        statusChar = nil
        
        //try to reconnect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            central.connect(peripheral, options: nil)
        }
    }
}







// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        guard let services = peripheral.services else { return }
        for s in services where s.uuid == BLEIDs.service {
            peripheral.discoverCharacteristics([BLEIDs.cmd, BLEIDs.status], for: s)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard error == nil else { return }
        guard let chars = service.characteristics else { return }
        
        for c in chars {
            if c.uuid == BLEIDs.cmd { cmdChar = c }
            if c.uuid == BLEIDs.status { statusChar = c }
        }
        
        // subscribe to status notifications (minimal)
        if let statusChar {
            peripheral.setNotifyValue(true, for: statusChar)
        }
    }
    //UPDATE THREAD IMPORTANT
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        
        let text = String(decoding: data, as: UTF8.self)
        
        if characteristic.uuid == BLEIDs.status {
            // 1. Trim whitespace/newlines to prevent Double() from failing
            let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 2. Use 'if let' to safely parse the number
            if let numericValue = Double(cleanText) {
                // 3. Ensure the UI update happens on the Main Thread
                Task { @MainActor in
                    self.statusText = cleanText
                    self.statusInt = numericValue
                    print("Updated statusInt to: \(numericValue)") // Debugging help
                    }
            } else {
                print("Failed to parse BLE data: '\(text)'")
            }
        }
    }
}

extension BLEManager {
    //fix my previews...
    static var mock: BLEManager {
        let manager = BLEManager(startCentral: false)
        manager.statusInt = 1500 // Give it a sample value
        manager.statusText = "1500"
        manager.isConnected = true
        return manager
    }
}
