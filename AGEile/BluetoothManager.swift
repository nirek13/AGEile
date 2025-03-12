import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var peripheralNames: [String] = [] 
    @Published var isScanning = false  // Add isScanning property
    
    private var centralManager: CBCentralManager!
    private var connectingPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Start scanning if Bluetooth is powered on during initialization
        if centralManager.state == .poweredOn {
            startScanning()
        }
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            isScanning = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()  // Start scanning when Bluetooth is powered on
        } else {
            stopScanning()  // Stop scanning if Bluetooth is not powered on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Avoid adding duplicates to discoveredDevices
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectingPeripheral?.delegate = self
    }
    
    func disconnect() {
        if let peripheral = connectingPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            isConnected = false
        }
    }

    // Optional error handling method
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.identifier): \(error?.localizedDescription ?? "Unknown error")")
    }
}

