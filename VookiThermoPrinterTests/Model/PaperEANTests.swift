//
//  PaperEANTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 10.08.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110


final class paperEANTests: XCTestCase {    
    func testIntegrity() {
        XCTAssertTrue(PaperEAN.testIntegrity())
    }
    
    func testDPI() {
        let allDPI = PaperEAN.DPI.allCases
        XCTAssertEqual(allDPI.count, 2)
        XCTAssertTrue(allDPI.contains(.dpi203))
        XCTAssertTrue(allDPI.contains(.dpi300))
        XCTAssertEqual(PaperEAN.DPI.dpi203.rawValue, 203)
        XCTAssertEqual(PaperEAN.DPI.dpi300.rawValue, 300)
    }
    
    func testPixels() {
        PaperEAN.DPI.allCases.forEach({ dpi in
            {
                for ean in PaperEAN.allCases {
                    XCTAssertEqual(ean.printableSizeInPixels(dpi: dpi).width,
                                   PixelCalculator.pixels(lengthInMM: ean.printableSizeInMillimeters.width, dpi: dpi.rawValue),
                                   accuracy: 0.1)
                    XCTAssertEqual(ean.physicalSizeInPixels(dpi: dpi).width,
                                   PixelCalculator.pixels(lengthInMM: ean.physicalSizeInMillimeters.width, dpi: dpi.rawValue),
                                   accuracy: 0.1)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInPixels(dpi: dpi).width, ean.printableSizeInPixels(dpi: .dpi203).width)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInMillimeters.width, ean.printableSizeInMillimeters.width)
                    
                    XCTAssertEqual(ean.printableSizeInPixels(dpi: dpi).height,
                                   PixelCalculator.pixels(lengthInMM: ean.printableSizeInMillimeters.height, dpi: dpi.rawValue),
                                   accuracy: 0.1)
                    XCTAssertEqual(ean.physicalSizeInPixels(dpi: dpi).height,
                                   PixelCalculator.pixels(lengthInMM: ean.physicalSizeInMillimeters.height, dpi: dpi.rawValue),
                                   accuracy: 0.1)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInPixels(dpi: dpi).height, ean.printableSizeInPixels(dpi: .dpi203).height)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInMillimeters.height, ean.printableSizeInMillimeters.height)
                }
            }()
        })
    }
}
