//
//  Notify.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

protocol Notifier {
    func notify(name: Notification.Name)
    func notify(name: Notification.Name, userInfo: [String : Any])
    func notifyUI(name: Notification.Name)
    func notifyUI(name: Notification.Name, userInfo: [String : Any])
}
