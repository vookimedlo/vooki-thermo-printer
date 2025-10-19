/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

class PixelCalculator {
    private static let inchInMM = 25.4

    static func lengthInMM(pixels: Double, dpi: Double) -> Double {
        pixels * Self.inchInMM / dpi
    }

    static func pixels(lengthInMM: Double, dpi: Double) -> Double {
        round(dpi * lengthInMM / Self.inchInMM)
    }
    
    static func pixelsByteAligned(lengthInMM: Double, dpi: Double) -> Double {
        (dpi * lengthInMM / Self.inchInMM / Double(UInt8.bitWidth)).rounded(.down) * Double(UInt8.bitWidth)
    }
    
    static func bits(pixelWidth: Double, pixelHeight: Double, bitsPerPixel: UInt) -> Double {
        pixelWidth * pixelHeight * Double(bitsPerPixel)
    }
    
    static func bytes(pixelWidth: Double, pixelHeight: Double, bitsPerPixel: UInt) -> Double {
        self.bits(pixelWidth: pixelWidth, pixelHeight: pixelHeight, bitsPerPixel: bitsPerPixel) / 8
    }
}
