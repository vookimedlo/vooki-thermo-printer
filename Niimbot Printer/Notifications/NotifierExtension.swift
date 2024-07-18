//
//  NotifierExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

extension Notifier {
    nonisolated
    func notify(name: Notification.Name) {
        Dispatch.DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
        
    nonisolated
    func notify(name: Notification.Name, userInfo: [String : Sendable]) {
        Dispatch.DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
    
    nonisolated
    func notifyUI(name: Notification.Name) {
        Task { @MainActor in
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    nonisolated
    func notifyUI(name: Notification.Name, userInfo: [String : Sendable]) {
        Task { @MainActor in
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
    
    nonisolated
    func notifyUIAlert(alertType: AlertType) {
        Task { @MainActor in
            NotificationCenter.default.post(name: .App.UI.alert, object: nil, userInfo: [String : AlertType](dictionaryLiteral: (Notification.Keys.value, alertType)))
        }
    }
}
