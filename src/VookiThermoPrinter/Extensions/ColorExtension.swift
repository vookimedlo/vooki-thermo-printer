/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 0xFF,
            green: Double((hex >> 08) & 0xFF) / 0xFF,
            blue: Double((hex >> 00) & 0xFF) / 0xFF,
            opacity: alpha
        )
    }

    static var lila: Color {
        .init(hex: 0x9370DB)
    }
}
