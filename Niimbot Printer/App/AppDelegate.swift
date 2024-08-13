//
//  AppDelegate.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 02.08.2024.
//

import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let unwantedMenus = ["File", "View"]
    private static let keepPosition = [("Printer", 1)]

    private static func updateMenu() {
        Self.unwantedMenus.forEach {
            guard let menu = NSApp.mainMenu?.item(withTitle: $0) else { return }
            NSApp.mainMenu?.removeItem(menu)
        }
        
        Self.keepPosition.forEach {
            if NSApp.mainMenu?.item(at: $0.1)?.title != $0.0 {
                guard let menu = NSApp.mainMenu?.item(withTitle: $0.0) else { return }
                NSApp.mainMenu?.removeItem(menu)
                NSApp.mainMenu?.insertItem(menu, at: $0.1)
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            forName: NSMenu.didAddItemNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                Self.updateMenu()
            }
        }
        
        Self.updateMenu()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
