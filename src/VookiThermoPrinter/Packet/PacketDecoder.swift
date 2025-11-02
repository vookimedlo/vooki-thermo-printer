/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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
