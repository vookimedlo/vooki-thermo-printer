//
//  LabelTypePacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class LabelTypePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_LABEL_TYPE
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else { return false }
        guard packet.payload.count == 1 else { return false }
       
        notify(name: Notification.Name.App.labelType,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, packet.payload[0])))
        return true
    }
}
