//
//  StubbedFileSystem.swift
//  Niimbot PrinterTests
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation
@testable import VookiThermoPrinter

class StubbedFileSystem : FileSystemAccess {
    public var openResult: Int32 = -1
    public var closeResult: Int32 = -1
    public var readResult: Int = -1
    public var writeResult: Int = -1
    
    public var openCalled = 0
    public var closeCalled = 0
    public var readCalled = 0
    public var writeCalled = 0
    
    public var readOutputData: [UInt8] = []
    
    public var writeInputBuffer : [UInt8] = []
    public var writeInputBufferSize : Int = 0


    public func open(_ path: UnsafePointer<CChar>, _ oflag: Int32) -> Int32 {
        self.openCalled += 1
        return self.openResult
    }
    
    @discardableResult
    public func close(_ fileDescriptor: Int32) -> Int32 {
        self.closeCalled += 1
        return self.closeResult
    }
    
    public func read(_ fileDescriptor: Int32, _ buffer: UnsafeMutableRawPointer!, _ count: Int) -> Int {
        self.readCalled += 1
        buffer.copyMemory(from: &self.readOutputData, byteCount: count)
        return self.readResult
    }
    
    public func write(_ fileDescriptor: Int32, _ buffer: UnsafeRawPointer!, _ count: Int) -> Int {
        self.writeInputBuffer = Array<UInt8>(rawPointer: buffer, count: count)
        self.writeInputBufferSize = count
        self.writeCalled += 1
        return self.writeResult
    }
}
