//
//  Notify.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

protocol Notifier {
    nonisolated
    func notify(name: Notification.Name)
    
    nonisolated
    func notify(name: Notification.Name, userInfo: [String : Sendable])
    
    nonisolated
    func notifyUI(name: Notification.Name)
    
    nonisolated
    func notifyUI(name: Notification.Name, userInfo: [String : Sendable])
    
    nonisolated
    func notifyUIAlert(alertType: AlertType)
}
