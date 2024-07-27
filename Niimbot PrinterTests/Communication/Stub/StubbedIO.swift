//
//  StubbedIO.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 26.07.2024.
//

import Foundation
import Niimbot_Printer

class StubbedIO : IO {
    public var openResultThrows: Bool = false
    public var closeResult: Int32 = -1
    public var readResult: Int = -1
    public var readResultThrows: Bool = false
    public var writeResult: Int = -1
    public var writeResultThrows: Bool = false

    public var openCalled = 0
    public var closeCalled = 0
    public var readCalled = 0
    public var writeCalled = 0
    
    public var readOutputData: [UInt8] = []
    public var readOutputDataOnlyOnce: Bool = false

    
    public var writeInputBuffer : [UInt8] = []
    public var writeInputBufferSize : Int = 0
    
    public var name: String {
        return "stubbedIO for testing"
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
    
    public func readBytes(into buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        self.readCalled += 1
        if readResultThrows {
            throw IOError.read
        }
        if readOutputDataOnlyOnce && self.readCalled > 1 {
            return 0
        }
        buffer.initialize(from:  &self.readOutputData, count: size)
        return self.readResult
    }
    
    public func writeBytes(from buffer: UnsafeRawPointer, size: Int) throws -> Int {
        writeCalled += 1
        if writeResultThrows {
            throw IOError.write
        }
        writeInputBuffer = Array<UInt8>(rawPointer: buffer, count: size)
        writeInputBufferSize = size
        return self.writeResult
    }
}
