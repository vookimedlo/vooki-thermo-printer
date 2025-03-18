//
//  StaticNotifiable.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 02.08.2024.
//

import Foundation


protocol StaticNotifiable {
    nonisolated
    static func notify(name: Notification.Name)
    
    nonisolated
    static func notify(name: Notification.Name, userInfo: [String : Sendable])
    
    nonisolated
    static func notifyUI(name: Notification.Name)
    
    nonisolated
    static func notifyUI(name: Notification.Name, userInfo: [String : Sendable])
    
    nonisolated
    static func notifyUIAlert(alertType: AlertType)
}
