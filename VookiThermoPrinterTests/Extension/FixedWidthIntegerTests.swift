/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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

