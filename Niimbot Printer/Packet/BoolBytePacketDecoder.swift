//
//  BoolBytePacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

class BoolBytePacketDecoder: PacketDecoding {
    static let codes = [RequestCode.RESPONSE_START_PRINT,
                        RequestCode.RESPONSE_END_PRINT,
                        RequestCode.RESPONSE_START_PAGE_PRINT,
                        RequestCode.RESPONSE_END_PAGE_PRINT,
                        RequestCode.RESPONSE_ALLOW_PRINT_CLEAR,
                        RequestCode.RESPONSE_SET_LABEL_DENSITY,
                        RequestCode.RESPONSE_SET_LABEL_TYPE,
                        RequestCode.RESPONSE_SET_DIMENSION]
    
    func decode(packet: Packet) -> Bool {
        guard Self.codes.contains(packet.requestCode) else { return false }
        guard packet.payload.count == 1 else { return false }
        
        guard let name = { (code: RequestCode) -> NSNotification.Name? in
            switch packet.requestCode {
            case RequestCode.RESPONSE_START_PRINT:
                return Notifications.Names.startPrint
            case RequestCode.RESPONSE_END_PRINT:
                return Notifications.Names.endPrint
            case RequestCode.RESPONSE_START_PAGE_PRINT:
                return Notifications.Names.startPagePrint
            case RequestCode.RESPONSE_END_PAGE_PRINT:
                return Notifications.Names.endPagePrint
            case RequestCode.RESPONSE_ALLOW_PRINT_CLEAR:
                return Notifications.Names.allowPrintClear
            case RequestCode.RESPONSE_SET_LABEL_TYPE:
                return Notifications.Names.setLabelType
            case RequestCode.RESPONSE_SET_LABEL_DENSITY:
                return Notifications.Names.setLabelDensity
            case RequestCode.RESPONSE_SET_DIMENSION:
                return Notifications.Names.setDimension
            default:
                return nil
            }
        }(packet.requestCode) else {
            return false
        }
        
        let result = packet.payload[0] != 0

        notify(name: name,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, result)))
        return true
    }
}
