//
//  BluetoothAccessProtocol.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 03.06.2024.
//

import Foundation

public protocol BluetoothAccess {
    func open() throws
    func close()
    func write(from buffer: UnsafeRawPointer, size: Int) throws -> Int
    var name: String { get }
    
    func replaceConsumer(dataConsumer: DataConsumer)
}
