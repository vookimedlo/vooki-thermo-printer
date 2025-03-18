//
//  StubbedBluetoothAccess.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.07.2024.
//

import Foundation
@testable import VookiThermoPrinter

class StubbedBluetoothAccess: BluetoothAccess {
    
    public var openResultThrows: Bool = false
    public var closeResult: Int32 = -1
    public var writeResult: Int = -1
    public var writeResultThrows: Bool = false

    public var openCalled = 0
    public var closeCalled = 0
    public var replaceConsumerCalled = 0
    public var writeCalled = 0
        
    public var writeInputBuffer : [UInt8] = []
    public var writeInputBufferSize : Int = 0
    
    public var dataConsumer: DataConsumer? = nil
    
    public var name: String {
        return "StubbedBluetoothAccess for testing"
    }

    public func open() throws {
        openCalled += 1
        if openResultThrows {
            throw IOError.open
        }
    }
    
    
    public func close() {
        closeCalled += 1
    }
    
    func write(from buffer: UnsafeRawPointer, size: Int) throws -> Int {
        writeCalled += 1
        if writeResultThrows {
            throw IOError.write
        }
        writeInputBuffer = Array<UInt8>(rawPointer: buffer, count: size)
        writeInputBufferSize = size
        return self.writeResult
    }
        
    func replaceConsumer(dataConsumer: any DataConsumer) {
        replaceConsumerCalled += 1
        self.dataConsumer = dataConsumer
    }
}
