//
//  PrinterAppD110.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 27.05.2024.
//

import SwiftUI
import SwiftData

struct AppDetailsD110: AppDetails {
    var dpi: PaperEAN.DPI = .dpi203
    var printerVariant: String = "D110"
    var peripheralFilter: String = "D110_"
}

@main
struct PrinterAppD110: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Variant-specific base with 203 DPI
    @StateObject private var base: PrinterAppBase
    
    let appDetails = AppDetailsD110()

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
