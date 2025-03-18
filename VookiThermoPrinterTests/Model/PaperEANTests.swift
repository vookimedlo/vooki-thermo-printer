//
//  PaperEANTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 10.08.2024.
//

import XCTest
@testable import Niimbot_Printer


final class paperEANTests: XCTestCase {
    let dpi = 203.0
    
    func testIntegrity() {
        XCTAssertTrue(PaperEAN.testIntegrity())
    }
    
    func testPixels() {
        for ean in PaperEAN.allCases {
            XCTAssertEqual(ean.printableSizeInPixels.width,
                           PixelCalculator.pixels(lengthInMM: ean.printableSizeInMillimeters.width, dpi: dpi),
                           accuracy: 0.1)
            XCTAssertEqual(ean.physicalSizeInPixels.width,
                           PixelCalculator.pixels(lengthInMM: ean.physicalSizeInMillimeters.width, dpi: dpi),
                           accuracy: 0.1)
            XCTAssertGreaterThanOrEqual(ean.physicalSizeInPixels.width, ean.printableSizeInPixels.width)
            XCTAssertGreaterThanOrEqual(ean.physicalSizeInMillimeters.width, ean.printableSizeInMillimeters.width)
            
            XCTAssertEqual(ean.printableSizeInPixels.height,
                           PixelCalculator.pixels(lengthInMM: ean.printableSizeInMillimeters.height, dpi: dpi),
                           accuracy: 0.1)            
            XCTAssertEqual(ean.physicalSizeInPixels.height,
                           PixelCalculator.pixels(lengthInMM: ean.physicalSizeInMillimeters.height, dpi: dpi),
                           accuracy: 0.1)
            XCTAssertGreaterThanOrEqual(ean.physicalSizeInPixels.height, ean.printableSizeInPixels.height)
            XCTAssertGreaterThanOrEqual(ean.physicalSizeInMillimeters.height, ean.printableSizeInMillimeters.height)
        }
    }
}
