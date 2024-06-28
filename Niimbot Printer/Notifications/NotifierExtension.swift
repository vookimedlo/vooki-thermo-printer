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
            NotificationCenter.default.post(name: name, object: self)
        }
    }
    
    func notify(name: Notification.Name, userInfo: [String : Any]) {
        Dispatch.DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
        }
    }
    
    func notifyUI(name: Notification.Name) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: self)
        }
    }
    
    func notifyUI(name: Notification.Name, userInfo: [String : Any]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
        }
    }
}
