//
//  BluetoothSupport.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 03.06.2024.
//

import Foundation
import CoreBluetooth
import os

class BluetoothSupport : NSObject, BluetoothAccess, Notifier, CBCentralManagerDelegate, CBPeripheralDelegate {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: BluetoothSupport.self)
    )
    
    let characteristicUUID = CBUUID(string: "bef8d6c9-9c21-4c9e-b632-bd58c1009f9f")
    let serviceUUID = CBUUID(string: "e7810a71-73ae-499d-8c15-faa9aef0c3f2")
    
    weak var dataConsumer: DataConsumer?
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    var name: String {
        return peripheral?.name ?? ""
    }
    
    var isConnectedPrinter: Bool = false

    static let centralManager = CBCentralManager(delegate: nil, queue: DispatchQueue(label: "CentralManager"))
    
    let connectSemaphore = DispatchSemaphore(value: 0)
    let disconnectSemaphore = DispatchSemaphore(value: 0)
    
    override init() {
        super.init()
        Self.centralManager.delegate = self
    }
    
    init(peripheral: CBPeripheral) {
        super.init()
        Self.centralManager.delegate = self
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        Self.logger.info("Peripheral name: \(peripheral.name ?? " ")")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                Self.logger.info("Bluetooth state: Powered off.")
            case .poweredOn:
                Self.logger.info("Bluetooth state: Powered on.")
            case .unsupported:
                Self.logger.info("Bluetooth state: Unsupported.")
            case .unauthorized:
                Self.logger.info("Bluetooth state: Unauthorized.")
            case .unknown:
                Self.logger.info("Bluetooth state: Unknown.")
            case .resetting:
                Self.logger.info("Bluetooth state: Resetting.")
            @unknown default:
                Self.logger.error("Bluetooth state: Unknow state.")
            }
    }
    
    func startScanning() -> Void {
        Self.centralManager.scanForPeripherals(withServices: nil)
    }
    
    func stopScanning() -> Void {
        Self.centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        notify(name: Notification.Name.App.bluetoothPeripheralDiscovered,
               userInfo: [String : BluetoothPeripheral](dictionaryLiteral: (Notification.Keys.peripheral,
                                                                            BluetoothPeripheral(peripheral: peripheral))))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        guard self.peripheral?.identifier == peripheral.identifier else { return }
        connectSemaphore.signal()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard self.peripheral?.identifier == peripheral.identifier else { return }
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral: CBPeripheral, error: (any Error)?) {
        guard self.peripheral?.identifier == didDisconnectPeripheral.identifier else { return }
        disconnectSemaphore.signal()
        notify(name: Notification.Name.App.bluetoothPeripheralDisconnected)
    }
    

    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard error == nil else { return }
        guard self.peripheral?.identifier == peripheral.identifier else { return }
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID],
                                                   for: service)
                return
            }
        }
        connectSemaphore.signal()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard self.peripheral?.identifier == peripheral.identifier else { return }
        guard serviceUUID == service.uuid else { return }
        guard error == nil else { return }
        guard let characteristics = service.characteristics else { return }
        defer {
            connectSemaphore.signal()
        }
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                self.characteristic = characteristic
                self.peripheral?.setNotifyValue(true, for: characteristic)
                isConnectedPrinter = true
                return
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard self.peripheral?.identifier == peripheral.identifier else { return }
        guard self.characteristicUUID == characteristic.uuid else { return }
        guard error == nil else { return }
        guard let data = characteristic.value else { return }
        self.dataConsumer?.consumeData(data: data)
    }
    
    func open() throws {
        guard let peripheral = self.peripheral else { return }
        if peripheral.state == .connected {
            close()
        }
        isConnectedPrinter = false
        Self.centralManager.connect(self.peripheral!)
        connectSemaphore.wait()
        guard isConnectedPrinter else {
            throw IOError.open
        }
    }
    
    func close() {
        guard let peripheral = self.peripheral else { return }
        guard peripheral.state == .connected else { return }
        
        Self.centralManager.cancelPeripheralConnection(self.peripheral!)
        disconnectSemaphore.wait()
        self.characteristic = nil
    }
    
    func write(from buffer: UnsafeRawPointer, size: Int) throws -> Int {
        guard let peripheral = self.peripheral else { throw IOError.write }
        guard peripheral.state == .connected else { throw IOError.write }
        guard let characteristic = self.characteristic else { throw IOError.write }
        self.peripheral?.writeValue(Data(bytes: buffer, count: size),
                              for: characteristic,
                              type: CBCharacteristicWriteType.withoutResponse)
        return size
    }
    
    func replaceConsumer(dataConsumer: DataConsumer) {
        self.dataConsumer = dataConsumer
    }
}
