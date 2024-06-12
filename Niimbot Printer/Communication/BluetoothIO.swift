//
//  BluetoothIO.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 02.06.2024.
//

import Foundation
import os


class BluetoothIO : IO, DataConsumer {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: BluetoothIO.self)
    )
    
    let bluetoothAccess: BluetoothAccess
    
    var incomingData: Data
    let incomingDataLock = NSLock()
    let incomingDataSemaphore = DispatchSemaphore(value: 0)
        
    public init(bluetoothAccess: BluetoothAccess) {
        self.bluetoothAccess = bluetoothAccess
        incomingData = Data(capacity: 64)
        self.bluetoothAccess.replaceConsumer(dataConsumer: self)
    }
    
    public func open() throws {
        incomingDataLock.lock()
        incomingData.removeAll()
        incomingDataLock.unlock()
        
        try bluetoothAccess.open()
    }
    
    public func close() {
        bluetoothAccess.close()
    }
    
    public func readBytes(into buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        guard  DispatchTimeoutResult.success == incomingDataSemaphore.wait(timeout: .now().advanced(by: DispatchTimeInterval.milliseconds(250))) else { return 0 }
        
        incomingDataLock.lock()
        defer {
            incomingDataLock.unlock()
        }
        
        let numberOfProcessedData = min(incomingData.count, size)
        incomingData.copyBytes(to: buffer, count: numberOfProcessedData)
        incomingData.removeFirst(numberOfProcessedData)

        if !incomingData.isEmpty {
            // We need to set the semaphore back to 1 if other data are still available,
            // so nder lock we can wait for semaphore which succeeds or times-out immediatelly,
            // and then we can set the semaphore and have wanted signelled binary semaphore
            _ = incomingDataSemaphore.wait(timeout: DispatchTime.now())
            incomingDataSemaphore.signal()
        }
        
        return numberOfProcessedData
    }
    
    public func writeBytes(from buffer: UnsafeRawPointer, size: Int) throws -> Int {
        return try bluetoothAccess.write(from: buffer, size: size)
    }
    
    public func consumeData(data: Data) {
        incomingDataLock.lock()
        defer {
            incomingDataLock.unlock()
        }
        incomingData.append(data)
        
        // We need to set the semaphore back to 1 or keep it in the state of 1 signalled item
        // if other data are still available,
        // so nder lock we can wait for semaphore which succeeds or times-out immediatelly,
        // and then we can set the semaphore and have wanted signelled binary semaphore
        _ = incomingDataSemaphore.wait(timeout: .now())
        incomingDataSemaphore.signal()
    }
    
}
