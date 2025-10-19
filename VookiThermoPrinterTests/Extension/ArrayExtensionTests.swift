//
//  ArrayExtensionTests.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 23.07.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110

final class ArrayExtensionTests: XCTestCase {
    func testConstructor_fromUnsafePointer() {
        let input: [UInt] = [1, 2, 3, 4]
        let output = Array<UInt>(pointer: input, count: input.count)
        XCTAssertEqual(input, output)
    }
    
    func testConstructor_fromRawUnsafePointer() {
        let input: [UInt] = [1, 2, 3, 4]
        let output = Array<UInt>(rawPointer: input, count: input.count)
        XCTAssertEqual(input, output)
    }
    
    func testToUint16_not2InputBytes() {
        for fromBigEndian in [false, true] {
            let inputArray = [UInt8](arrayLiteral: 1)
            XCTAssertNil(inputArray.toUInt16(fromBigEndian: fromBigEndian))
            
            let inputArray2 = [UInt8](arrayLiteral: 1, 2, 3)
            XCTAssertNil(inputArray2.toUInt16(fromBigEndian: fromBigEndian))
        }
        
    }
    
    func testToUint16_2InputBytes() throws {
        for fromBigEndian in [false, true] {
            var inputArray = [UInt8](arrayLiteral: 0, 0)
            var result = try XCTUnwrap(inputArray.toUInt16(fromBigEndian: fromBigEndian))
            XCTAssertEqual(0, result)
            
            inputArray = [UInt8](arrayLiteral: 0xFF, 0xFF)
            result = try XCTUnwrap(inputArray.toUInt16(fromBigEndian: fromBigEndian))
            XCTAssertEqual(0xFFFF, result)
            
            inputArray = [UInt8](arrayLiteral: 0x12, 0x34)
            result = try XCTUnwrap(inputArray.toUInt16(fromBigEndian: fromBigEndian))
            XCTAssertEqual(fromBigEndian ? 0x1234 : 0x3412, result)
        }
        
    }
    
    private struct TestingElement: Equatable {
        let id = UUID().uuidString
        let value: Int
    }
    
    func testfindFirstMatching_Found() throws {
        let expectedItem = TestingElement(value: 20)
        var inputArray = [TestingElement]()
        inputArray.append(TestingElement(value: 10))
        inputArray.append(expectedItem)
        inputArray.append(TestingElement(value: 20))
        inputArray.append(TestingElement(value: 30))
        let result = inputArray.findFirstMatching { element in
            expectedItem.value == element.value
        }
        XCTAssertEqual(expectedItem, try XCTUnwrap(result))
    }
    
    func testfindFirstMatching_NotFound() throws {
        let expectedItem = TestingElement(value: 60)
        var inputArray = [TestingElement]()
        inputArray.append(TestingElement(value: 10))
        inputArray.append(TestingElement(value: 20))
        inputArray.append(TestingElement(value: 30))
        let result = inputArray.findFirstMatching { element in
            expectedItem.value == element.value
        }
        XCTAssertNil(result)
    }
}
