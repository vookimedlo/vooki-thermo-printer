//
//  PixelCalculatorTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 13.08.2024.
//

import XCTest
@testable import VookiThermoPrinter

final class PixelCalculatorTests: XCTestCase {
    func testLengthInMM() {
        XCTAssertEqual(0.12512315270935960591, PixelCalculator.lengthInMM(pixels: 1, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(12.512315270935960591, PixelCalculator.lengthInMM(pixels: 100, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(31.2807881773399014775, PixelCalculator.lengthInMM(pixels: 250, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(43.7931034482758620685, PixelCalculator.lengthInMM(pixels: 350, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(1, PixelCalculator.lengthInMM(pixels: 8, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(250, PixelCalculator.lengthInMM(pixels: 1998, dpi: 203), accuracy: 0.01)
    }
    
    func testPixels() {
        XCTAssertEqual(1, PixelCalculator.pixels(lengthInMM: 0.12512315270935960591, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(100, PixelCalculator.pixels(lengthInMM: 12.512315270935960591, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(250, PixelCalculator.pixels(lengthInMM: 31.2807881773399014775, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(350, PixelCalculator.pixels(lengthInMM: 43.7931034482758620685, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(8, PixelCalculator.pixels(lengthInMM: 1, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(799, PixelCalculator.pixels(lengthInMM: 100, dpi: 203), accuracy: 0.01)
        XCTAssertEqual(1998, PixelCalculator.pixels(lengthInMM: 250, dpi: 203), accuracy: 0.01)
    }
    
    func testBits() {
        XCTAssertEqual(1200, PixelCalculator.bits(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 1))
        XCTAssertEqual(9600, PixelCalculator.bits(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 8))
        XCTAssertEqual(19200, PixelCalculator.bits(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 16))
        XCTAssertEqual(28800, PixelCalculator.bits(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 24))
    }
    
    func testBytes() {
        XCTAssertEqual(150, PixelCalculator.bytes(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 1))
        XCTAssertEqual(1200, PixelCalculator.bytes(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 8))
        XCTAssertEqual(2400, PixelCalculator.bytes(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 16))
        XCTAssertEqual(3600, PixelCalculator.bytes(pixelWidth: 20, pixelHeight: 60, bitsPerPixel: 24))
    }
}
