//
//  PacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation
import os

protocol PacketDecoding: Notifier {
    func decode(packet: Packet) -> Bool
}

class PacketDecoder: PacketDecoding, Observable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UplinkProcessor.self)
    )

    var decoders: [PacketDecoding]
    
    init(decoders: [PacketDecoding]) {
        self.decoders = decoders
        registerNotification(name: Notifications.Names.uplinkedPacket, selector: #selector(receiveNotification))
    }
    
    func decode(packet: Packet) -> Bool {
        for decoder in decoders {
            if decoder.decode(packet: packet) {
                return true
            }
        }
        return false
    }
    
    @objc func receiveNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        if Notifications.Names.uplinkedPacket ==  notification.name {
            let packet = notification.userInfo?[Notifications.Keys.packet] as! Packet
            guard decode(packet: packet) else {
                Self.logger.warning("Packet cannot be decoded")
                return
            }
        }
    }
}
