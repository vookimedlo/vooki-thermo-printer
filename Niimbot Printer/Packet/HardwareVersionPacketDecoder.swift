//
//  HardwareVersionPacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class HardwareVersionPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_HARDWARE_VERSION
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let integerVersion = packet.payload.toUInt16() else {
            return false
        }
        
        let version: Float = Float(integerVersion) / 100

        notify(name: Notification.Name.App.hardwareVersion,
               userInfo: [String : Any](dictionaryLiteral: (Notification.Keys.value, version)))
        return true
    }
}
