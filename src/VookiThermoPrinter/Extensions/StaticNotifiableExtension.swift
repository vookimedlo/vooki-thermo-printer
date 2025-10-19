/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation


extension StaticNotifiable {
    nonisolated
    public static func notify(name: Notification.Name) {
        Task { @PrinterActor in
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
        
    nonisolated
    public static func notify(name: Notification.Name, userInfo: [String : Sendable]) {
        Task { @PrinterActor in
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
    
    nonisolated
    public static func notifyUI(name: Notification.Name) {
        Task { @MainActor in
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    nonisolated
    public static func notifyUI(name: Notification.Name, userInfo: [String : Sendable]) {
        Task { @MainActor in
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
    
    nonisolated
    public static func notifyUIAlert(alertType: AlertType) {
        Task { @MainActor in
            NotificationCenter.default.post(name: .App.UI.alert, object: nil, userInfo: [String : AlertType](dictionaryLiteral: (Notification.Keys.value, alertType)))
        }
    }
}
