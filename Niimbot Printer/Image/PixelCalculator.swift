//
//  PixelCalculator.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 13.08.2024.
//

import Foundation

class PixelCalculator {
    private static let inchInMM = 25.4

    static func lengthInMM(pixels: Double, dpi: Double) -> Double {
        pixels * Self.inchInMM / dpi
    }

    static func pixels(lengthInMM: Double, dpi: Double) -> Double {
        round(dpi * lengthInMM / Self.inchInMM)
    }
    
    static func bits(pixelWidth: Double, pixelHeight: Double, bitsPerPixel: UInt) -> Double {
        pixelWidth * pixelHeight * Double(bitsPerPixel)
    }
    
    static func bytes(pixelWidth: Double, pixelHeight: Double, bitsPerPixel: UInt) -> Double {
        self.bits(pixelWidth: pixelWidth, pixelHeight: pixelHeight, bitsPerPixel: bitsPerPixel) / 8
    }
}
