//
//  SerialNumberPacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

public class SerialNumberPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_SERIAL
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }

        notify(name: Notification.Name.App.serialNumber,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, String(decoding: packet.payload, as: UTF8.self))))
        return true
    }
}
