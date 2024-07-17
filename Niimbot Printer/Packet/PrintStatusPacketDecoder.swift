//
//  RFIDDataPacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

struct PrintStatus {
    let page: UInt16
    let progress1: UInt8
    let progress2: UInt8
}

class PrintStatusPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_PRINT_STATUS
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard packet.payload.count == 4 else {
            return false
        }
        
        var data = Data(bytes: packet.payload, count: packet.payload.count)
        
        let uint16Size = UInt16.bitWidth / 8
        let page = [UInt8](data[data.startIndex..<data.startIndex + uint16Size]).toUInt16()!
        data.removeFirst(uint16Size)

        let progress1 = data.removeFirst()
        let progress2 = data.removeFirst()

        notify(name: Notification.Name.App.getPrintStatus,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, PrintStatus(page: page,
                                                                                                 progress1: progress1,
                                                                                                 progress2: progress2))))
        return true
    }
}
