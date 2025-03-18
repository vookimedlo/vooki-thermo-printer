//
//  BluetoothIOTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.07.2024.
//

import XCTest
@testable import VookiThermoPrinter

final class BluetoothIOTests: XCTestCase {
    func testOpen_Throws() throws {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        stubbedBluetoothAccess.openResultThrows = true
        
        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        XCTAssertThrowsError(try io.open()) { error in
            XCTAssertEqual(error as! IOError, IOError.open)
        }
        XCTAssertEqual(1, stubbedBluetoothAccess.openCalled)
    }

    func testOpen_DontThrows() throws {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        stubbedBluetoothAccess.openResultThrows = false
        
        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        XCTAssertNoThrow(try io.open())
        XCTAssertEqual(1, stubbedBluetoothAccess.openCalled)
    }
    
    func testOpen_DontThrowsAndClearsDataBuffer() throws {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        stubbedBluetoothAccess.openResultThrows = false
        
        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        XCTAssertNoThrow(try io.open())
        XCTAssertEqual(1, stubbedBluetoothAccess.openCalled)
        
        // write 3 bytes so those bytes are now in the unread buffer
        let data = Data([UInt8](arrayLiteral: 1, 2, 3))
        stubbedBluetoothAccess.dataConsumer?.consumeData(data: data)

        var output = [UInt8](arrayLiteral: 0, 0, 0)
        
        // read a single byte, so 2 are still in the unread buffer
        var result = try io.readBytes(into: &output, size: 1)
        XCTAssertEqual(1, result)

        io.close()
        XCTAssertEqual(1, stubbedBluetoothAccess.closeCalled)

        // open shall cause depletation of unread buffer
        XCTAssertNoThrow(try io.open())
        XCTAssertEqual(2, stubbedBluetoothAccess.openCalled)
        
        result = try io.readBytes(into: &output, size: 1)
        XCTAssertEqual(0, result)
    }
    
    func testClose() throws {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        
        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        io.close()
        XCTAssertEqual(1, stubbedBluetoothAccess.closeCalled)
    }
    
    func testReadBytes_Returns0WhenNoDataAreAvailable() throws {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()

        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        var output = [UInt8](arrayLiteral: 0, 0, 0)
        
        // read a single byte, so 2 are still in the unread buffer
        let result = try io.readBytes(into: &output, size: 1)
        XCTAssertEqual(0, result)
    }
    
    func testReadBytes_ReturnsDataWhenNoDataAreAvailable() throws {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()

        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        let data = Data([UInt8](arrayLiteral: 1, 2, 3))
        stubbedBluetoothAccess.dataConsumer?.consumeData(data: data)
        
        var output = [UInt8](arrayLiteral: 0xAA, 0xAA, 0xAA, 0xAA)
        
        // read a single byte, so 2 are still in the unread buffer
        let result = try io.readBytes(into: &output, size: output.count)
        XCTAssertEqual(data.count, result)
        
        XCTAssertEqual(data[data.startIndex..<data.endIndex], Data(output[0..<3]))
        XCTAssertEqual(0xAA, output[3])
    }
    
    func testWriteBytes_FailesAndThrows() throws {
        var buffer: [UInt8] = []
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        stubbedBluetoothAccess.writeResultThrows = true

        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        XCTAssertThrowsError(try io.writeBytes(from: &buffer, size: 0)) { error in
            XCTAssertEqual(error as! IOError, IOError.write)
        }
        XCTAssertEqual(1, stubbedBluetoothAccess.writeCalled)
    }
    
    func testWriteBytes_SuccessfullyProcessedInputData() throws {
        var buffer: [UInt8] = [1,2]
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        stubbedBluetoothAccess.writeResult = buffer.count

        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)

        let result = try io.writeBytes(from: &buffer, size: buffer.count)
        XCTAssertEqual(1, stubbedBluetoothAccess.writeCalled)
        XCTAssertEqual(2, result)
        XCTAssertEqual(buffer, stubbedBluetoothAccess.writeInputBuffer)
    }
    
    func testName() {
        let stubbedBluetoothAccess = StubbedBluetoothAccess()
        let io = BluetoothIO(bluetoothAccess: stubbedBluetoothAccess)
        XCTAssertEqual(stubbedBluetoothAccess.name, io.name)
    }
}
