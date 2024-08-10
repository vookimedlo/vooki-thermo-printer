//
//  PaperEANTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 10.08.2024.
//

import XCTest
@testable import Niimbot_Printer


final class paperEANTests: XCTestCase {
    func testIntegrity() {
        XCTAssertTrue(PaperEAN.testIntegrity())
    }
}
