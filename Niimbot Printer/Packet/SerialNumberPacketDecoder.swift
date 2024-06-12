//
//  SerialNumberPacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class SerialNumberPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_SERIAL
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }

        notify(name: Notifications.Names.serialNumber,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, String(cString: packet.payload + [0]))))
        return true
    }
}
