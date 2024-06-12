//
//  DeviceTypePacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class DeviceTypePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_TYPE
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let deviceType = packet.payload.toUInt16() else {
            return false
        }

        notify(name: Notifications.Names.deviceType,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, deviceType)))
        return true
    }
}
