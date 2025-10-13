//
//  PrinterAppD110.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import SwiftUI
import SwiftData

@main
struct PrinterAppD11H: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Variant-specific base with 203 DPI
    @StateObject private var base: PrinterAppBase

    init() {
        // Build the base instance locally so we can pass it as inout before assigning to @StateObject
        var baseRef = PrinterAppBase(dpi: .dpi300)
        if !TestHelper.isRunningTests {
            baseRef.appLogic = AppLogic(appRef: &baseRef, dpi: .dpi300)
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
