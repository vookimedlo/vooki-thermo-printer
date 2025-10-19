/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation
import SwiftUI

@MainActor
@Observable
final class PaperDetails: ObservableObject {
    var serialNumber: String = "N/A"
    var remainingCount: String = "N/A"
    var printedCount: String = "N/A"
    var barcode: String = "N/A"
    var type: String = "N/A"
    var colorName: String = "N/A"
    var color: Color = .clear
    
    func clear() {
        serialNumber = "N/A"
        remainingCount = "N/A"
        printedCount = "N/A"
        barcode = "N/A"
        type = "N/A"
        colorName = "N/A"
        color = .clear
    }
}
