/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2025 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

protocol AppDetails: Sendable {
    var dpi: PaperEAN.DPI { get }
    var printerVariant: String { get }
    var peripheralFilter: String { get }
}

struct DefaultAppDetails: AppDetails {
    let dpi: PaperEAN.DPI
    let printerVariant: String
    let peripheralFilter: String
    
    static var defaultValue: AppDetails {
        DefaultAppDetails(
            dpi: .dpi300,
            printerVariant: "GenericPrinter",
            peripheralFilter: ""
        )
    }
}
