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
        
        print("density")
        print(packet.payload.hexEncodedString(options: [.upperCase]))
       
        notify(name: Notifications.Names.density,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, packet.payload[0])))
        return true
    }
}
