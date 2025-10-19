//
//  StaticNotifiableExtension.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 02.08.2024.
//

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
