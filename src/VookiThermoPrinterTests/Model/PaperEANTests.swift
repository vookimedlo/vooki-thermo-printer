/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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
                                   PixelCalculator.pixels(lengthInMM: ean.printableSizeInMillimeters.width, dpi: Double(dpi.rawValue)),
                                   accuracy: 0.1)
                    XCTAssertEqual(ean.physicalSizeInPixels(dpi: dpi).width,
                                   PixelCalculator.pixels(lengthInMM: ean.physicalSizeInMillimeters.width, dpi: Double(dpi.rawValue)),
                                   accuracy: 0.1)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInPixels(dpi: dpi).width, ean.printableSizeInPixels(dpi: dpi).width)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInMillimeters.width, ean.printableSizeInMillimeters.width)
                    
                    XCTAssertEqual(ean.printableSizeInPixels(dpi: dpi).height,
                                   PixelCalculator.pixelsByteAligned(lengthInMM: ean.printableSizeInMillimeters.height, dpi: Double(dpi.rawValue)),
                                   accuracy: 0.1)
                    XCTAssertEqual(ean.physicalSizeInPixels(dpi: dpi).height,
                                   PixelCalculator.pixels(lengthInMM: ean.physicalSizeInMillimeters.height, dpi: Double(dpi.rawValue)),
                                   accuracy: 0.1)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInPixels(dpi: dpi).height, ean.printableSizeInPixels(dpi: dpi).height)
                    XCTAssertGreaterThanOrEqual(ean.physicalSizeInMillimeters.height, ean.printableSizeInMillimeters.height)
                }
            }()
        })
    }
}
