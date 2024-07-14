//
//  NotifierExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

extension Notifier {
    func notify(name: Notification.Name) {
        Dispatch.DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    func notify(name: Notification.Name, userInfo: [String : Any]) {
        Dispatch.DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
    
    func notifyUI(name: Notification.Name) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    func notifyUI(name: Notification.Name, userInfo: sending [String : Any]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
        }
    }
    
    func notifyUIAlert(alertType: AlertType) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .App.UI.alert, object: nil, userInfo: [String : AlertType](dictionaryLiteral: (Notification.Keys.value, alertType)))
        }
    }
}
