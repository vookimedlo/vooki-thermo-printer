//
//  FixedWidthIntegerTests.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 26.07.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110

final class FixedWidthIntegerTests: XCTestCase {
    func testBytes() {
        let input: UInt64 = 0x1234567890
        let expected: [UInt8] = [0x90, 0x78, 0x56, 0x34, 0x12, 0x00, 0x00, 0x00]
        let result = input.bytes
        XCTAssertEqual(expected, result)
    }
    
}
