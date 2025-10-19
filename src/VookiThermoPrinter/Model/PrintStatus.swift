/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

public struct PrintStatus: Sendable, Equatable {
    public init(page: UInt16, progress1: UInt8, progress2: UInt8) {
        self.page = page
        self.progress1 = progress1
        self.progress2 = progress2
    }
    
    let page: UInt16
    let progress1: UInt8
    let progress2: UInt8
}
