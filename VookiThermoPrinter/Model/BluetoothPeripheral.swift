//
//  BluetoothPeripheral.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 19.06.2024.
//

import Foundation
import CoreBluetooth

@Observable
final class BluetoothPeripheral : Identifiable, @unchecked Sendable {
    var identifier: UUID
    var name: String
    var peripheral: CBPeripheral?
    
    init(peripheral: CBPeripheral) {
        self.identifier = peripheral.identifier
        self.name = peripheral.name ?? ""
        self.peripheral = peripheral
    }
    
    init(testing name: String) {
        self.identifier = UUID()
        self.name = name
    }
}

@Observable
final class BluetoothPeripherals : ObservableObject {
    private var _peripherals : [BluetoothPeripheral] = []
    var peripherals : [BluetoothPeripheral] {
            return _peripherals
        }
    
    func add(peripheral: BluetoothPeripheral) {
        guard !(_peripherals.contains { item in
            return item.identifier == peripheral.identifier
        }) else { return }
        guard !peripheral.name.isEmpty else { return }
        _peripherals.append(peripheral)
    }
    
    func find(identifier: UUID) -> BluetoothPeripheral? {
        return _peripherals.first { peripheral in
            return identifier == peripheral.identifier
        }
    }
    
    func removeAll() {
        _peripherals.removeAll()
    }

    var printersBasedOnName: (_ startsWith: String) -> [BluetoothPeripheral] {
        { startsWith in
            self.peripherals.filter { peripheral in
                peripheral.peripheral?.name?.starts(with: startsWith) ?? false
            }
        }
    }
}
