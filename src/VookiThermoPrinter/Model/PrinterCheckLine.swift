/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

public struct PrinterCheckLine: Sendable, Equatable {
    public init(lineNumber: UInt16, something: UInt8) {
        self.lineNumber = lineNumber
        self.something = something
    }
    
    let lineNumber: UInt16
    let something: UInt8
}
