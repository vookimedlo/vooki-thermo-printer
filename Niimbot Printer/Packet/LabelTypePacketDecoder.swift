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
        
        print("label")
        print(packet.payload.hexEncodedString(options: [.upperCase]))
       
        notify(name: Notifications.Names.labelType,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, packet.payload[0])))
        return true
    }
}
