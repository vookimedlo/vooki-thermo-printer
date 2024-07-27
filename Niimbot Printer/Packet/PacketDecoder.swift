//
//  PacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation
import os

public protocol PacketDecoding: Notifiable {
    func decode(packet: Packet) -> Bool
}

public class PacketDecoder: PacketDecoding, NotificationObservable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UplinkProcessor.self)
    )

    private let decoders: [PacketDecoding]
    
    public init(decoders: [PacketDecoding]) {
        self.decoders = decoders
        registerNotification(name: Notification.Name.App.uplinkedPacket, selector: #selector(receiveNotification))
    }
    
    public func decode(packet: Packet) -> Bool {
        for decoder in decoders {
            if decoder.decode(packet: packet) {
                return true
            }
        }
        return false
    }
    
    @objc func receiveNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        if Notification.Name.App.uplinkedPacket ==  notification.name {
            let packet = notification.userInfo?[Notification.Keys.packet] as! Packet
            guard decode(packet: packet) else {
                Self.logger.warning("Packet cannot be decoded")
                return
            }
        }
    }
}
