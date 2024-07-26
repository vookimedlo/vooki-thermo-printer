//
//  PrinterDeviceTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 26.07.2024.
//

import XCTest
import Niimbot_Printer

final class PrinterDeviceTests: XCTestCase {
    func testOpen_DontThrow() {
        let io = StubbedIO()
        io.openResultThrows = false
        let device = PrinterDevice(io: io)
        XCTAssertNoThrow(try device.open())
        XCTAssertEqual(1, io.openCalled)
    }
    
    func testOpen_Throws() {
        let io = StubbedIO()
        io.openResultThrows = true
        let device = PrinterDevice(io: io)
        XCTAssertThrowsError(try device.open())
        XCTAssertEqual(1, io.openCalled)
    }
    
    func testClose() {
        let io = StubbedIO()
        let device = PrinterDevice(io: io)
        device.close()
        XCTAssertEqual(1, io.closeCalled)
    }
    
    func testUplink_Throws() {
        let io = StubbedIO()
        io.readResultThrows = true
        let device = PrinterDevice(io: io)
        XCTAssertThrowsError(try device.uplink(ofLength: 5))
        XCTAssertEqual(1, io.readCalled)
    }
    
    func testUplink_ProvidesUplink() throws {
        let io = StubbedIO()
        io.readResultThrows = false
        io.readOutputData = [1, 2, 3, 4, 5]
        io.readResult = io.readOutputData.count
        let device = PrinterDevice(io: io)
        let result = try device.uplink(ofLength: 5)
        XCTAssertEqual(1, io.readCalled)
        XCTAssertEqual(io.readOutputData, result)
    }
    
    func testDownlink_Throws() {
        let io = StubbedIO()
        io.writeResultThrows = true
        let device = PrinterDevice(io: io)
        XCTAssertThrowsError(try device.downlink(from: [1, 2, 3]))
        XCTAssertEqual(1, io.writeCalled)
    }
    
    func testDownlink_WritesDownlink() throws {
        let input: [UInt8] = [1, 2, 3]
        let io = StubbedIO()
        io.writeResultThrows = false
        io.writeResult = input.count
        let device = PrinterDevice(io: io)
        let result = try device.downlink(from: input)
        XCTAssertEqual(1, io.writeCalled)
        XCTAssertEqual(input, io.writeInputBuffer)
        XCTAssertEqual(io.writeResult, result)
    }
    
}
