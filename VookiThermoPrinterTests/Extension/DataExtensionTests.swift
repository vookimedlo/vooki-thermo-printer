//
//  DataExtensionTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 25.07.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110

final class DataExtensionTests: XCTestCase {
    func testToUint16_not2InputBytes() {
        for fromBigEndian in [false, true] {
            let inputArray = [UInt8](arrayLiteral: 1)
            let inputData = Data(inputArray)
            XCTAssertNil(inputData.toUInt16(fromBigEndian: fromBigEndian))
            
            let inputArray2 = [UInt8](arrayLiteral: 1, 2, 3)
            let inputData2 = Data(inputArray2)
            XCTAssertNil(inputData2.toUInt16(fromBigEndian: fromBigEndian))
        }
        
    }
    
    func testToUint16_2InputBytes() throws {
        for fromBigEndian in [false, true] {
            var inputArray = [UInt8](arrayLiteral: 0, 0)
            var inputData = Data(inputArray)
            var result = try XCTUnwrap(inputData.toUInt16(fromBigEndian: fromBigEndian))
            XCTAssertEqual(0, result)
            
            inputArray = [UInt8](arrayLiteral: 0xFF, 0xFF)
            inputData = Data(inputArray)
            result = try XCTUnwrap(inputData.toUInt16(fromBigEndian: fromBigEndian))
            XCTAssertEqual(0xFFFF, result)
            
            inputArray = [UInt8](arrayLiteral: 0x12, 0x34)
            inputData = Data(inputArray)
            result = try XCTUnwrap(inputData.toUInt16(fromBigEndian: fromBigEndian))
            XCTAssertEqual(fromBigEndian ? 0x1234 : 0x3412, result)
        }
        
    }
}
