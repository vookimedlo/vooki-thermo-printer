//
//  NotificationObservableExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation
import Cocoa

extension NotificationObservable {
    func registerNotification(name: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func unregisterNotification(name: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
