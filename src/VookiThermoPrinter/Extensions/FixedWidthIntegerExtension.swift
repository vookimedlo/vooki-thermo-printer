/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

extension FixedWidthInteger {
    public var bytes: [UInt8] {
        var source = self
        return Array<UInt8>(rawPointer: &source, count: MemoryLayout<Self>.size)
    }
}
