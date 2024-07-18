//
//  RFIDDataPacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

struct RFIDData {
    let uuid: [UInt8]
    let barcode: String
    let serial: String
    let totalLength: UInt16
    let usedLength: UInt16
    let type: UInt8
}

class RFIDDataPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_RFID
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard packet.payload.count > 0 else {
            return false
        }
        
        if packet.payload[0] == 0 {
            notify(name: Notification.Name.App.noPaper)
            return true
        }
        
        var data = Data(bytes: packet.payload, count: packet.payload.count)
        
        let uuid = [UInt8](data[data.startIndex..<data.startIndex + 8])
        data.removeFirst(uuid.count)

        let barcodeLength = Int(data.removeFirst())
        let barcode = [UInt8](data[data.startIndex..<data.startIndex + barcodeLength])
        data.removeFirst(barcode.count)

        let serialLength = Int(data.removeFirst())
        let serial = [UInt8](data[data.startIndex..<data.startIndex + serialLength])
        data.removeFirst(serial.count)

        let uint16Size = UInt16.bitWidth / 8
        let totalLength = data[data.startIndex..<data.startIndex + uint16Size].toUInt16()!
        data.removeFirst(uint16Size)

        let usedLength = data[data.startIndex..<data.startIndex + uint16Size].toUInt16()!
        data.removeFirst(uint16Size)
        
        let type = data.removeFirst()
        notify(name: Notification.Name.App.rfidData,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, RFIDData(uuid: uuid,
                                                                                               barcode: String(decoding: barcode + [0], as: UTF8.self),
                                                                                               serial: String(decoding: serial + [0], as: UTF8.self),
                                                                                               totalLength: totalLength,
                                                                                               usedLength: usedLength,
                                                                                               type: type))))
        return true
    }
}
