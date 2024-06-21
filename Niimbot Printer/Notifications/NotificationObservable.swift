//
//  NotificationObservable.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

protocol NotificationObservable {
    func registerNotification(name: Notification.Name, selector: Selector)
    func unregisterNotification(name: Notification.Name)
    func unregisterNotifications()
}
