//
//  DeviceTypePacketDecoder.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

public class DeviceTypePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_TYPE
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let deviceType = packet.payload.toUInt16() else {
            return false
        }

        notify(name: Notification.Name.App.deviceType,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, deviceType)))
        return true
    }
}
