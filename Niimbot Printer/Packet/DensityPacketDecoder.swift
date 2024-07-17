//
//  DensityPacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class DensityPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DENSITY
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else { return false }
        guard packet.payload.count == 1 else { return false }
        
        notify(name: Notification.Name.App.density,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, packet.payload[0])))
        return true
    }
}
