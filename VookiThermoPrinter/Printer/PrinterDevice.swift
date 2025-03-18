//
//  PrinterDevice.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 28.05.2024.
//

import Foundation


public class PrinterDevice {
    let io : IO
    
    public init(io: IO) {
        self.io = io
    }
    
    public func open() throws {
        return try io.open()
    }
    
    public func close() {
        return io.close()
    }
        
    public func uplink(ofLength length: Int) throws -> [UInt8] {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        defer {
            buffer.deallocate()
        }

        let bytesRead = try io.readBytes(into: buffer, size: length)
        return Array<UInt8>(pointer: buffer, count: bytesRead)
     }
    
    public func downlink(from buffer: [UInt8]) throws -> Int {
        return try buffer.withUnsafeBytes({ (pointer: UnsafeRawBufferPointer) throws -> Int in
            guard let baseAddress = pointer.baseAddress else {
                throw IOError.write
            }
            return try io.writeBytes(from: baseAddress, size:buffer.count)
        })
    }
}
