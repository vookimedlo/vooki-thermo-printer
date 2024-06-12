//
//  AutoShutdownTimePacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class AutoShutdownTimePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_AUTO_SHUTDOWN_TIME
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else { return false }
        guard packet.payload.count == 1 else { return false }
       
        notify(name: Notifications.Names.autoShutdownTime,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, packet.payload[0])))
        return true
    }
}
