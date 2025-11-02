/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import SwiftUI
import SwiftData


struct AppDetailsD11H: AppDetails {
    var dpi: PaperEAN.DPI = .dpi300
    var printerVariant: String = "D11_H"
    var peripheralFilter: String = "D11_H-"
}

@main
struct PrinterAppD11H: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Variant-specific base with 300 DPI
    @StateObject private var base: PrinterAppBase
    
    let appDetails = AppDetailsD11H()
    
    init() {
        // Build the base instance locally so we can pass it as inout before assigning to @StateObject
        var baseRef = PrinterAppBase(appDetails: appDetails)
        if !TestHelper.isRunningTests {
            baseRef.appLogic = AppLogic(appRef: &baseRef, appDetails: appDetails)
        }
        _base = StateObject(wrappedValue: baseRef)
    }

    var body: some Scene {
        WindowGroup {
            base.rootContentView()
        }
        .modelContainer(base.container)
        .commands {
            base.commandsBuilder()
        }
    }
}
