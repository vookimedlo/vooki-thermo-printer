/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public final class BoolBytePacketDecoder: PacketDecoding {
    public static let codes = [RequestCode.RESPONSE_START_PRINT,
                        RequestCode.RESPONSE_END_PRINT,
                        RequestCode.RESPONSE_CANCEL_PRINT,
                        RequestCode.RESPONSE_START_PAGE_PRINT,
                        RequestCode.RESPONSE_END_PAGE_PRINT,
                        RequestCode.RESPONSE_ALLOW_PRINT_CLEAR,
                        RequestCode.RESPONSE_SET_LABEL_DENSITY,
                        RequestCode.RESPONSE_SET_LABEL_TYPE,
                        RequestCode.RESPONSE_SET_DIMENSION]
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.codes.contains(packet.requestCode) else { return false }
        guard packet.payload.count == 1 || (packet.requestCode == .RESPONSE_SET_DIMENSION && packet.payload.count == 2) else { return false }
        
        guard let name = { (code: RequestCode) -> NSNotification.Name? in
            switch packet.requestCode {
            case RequestCode.RESPONSE_START_PRINT:
                return Notification.Name.App.startPrint
            case RequestCode.RESPONSE_END_PRINT:
                return Notification.Name.App.endPrint
            case RequestCode.RESPONSE_CANCEL_PRINT:
                return Notification.Name.App.cancelPrint
            case RequestCode.RESPONSE_START_PAGE_PRINT:
                return Notification.Name.App.startPagePrint
            case RequestCode.RESPONSE_END_PAGE_PRINT:
                return Notification.Name.App.endPagePrint
            case RequestCode.RESPONSE_ALLOW_PRINT_CLEAR:
                return Notification.Name.App.allowPrintClear
            case RequestCode.RESPONSE_SET_LABEL_TYPE:
                return Notification.Name.App.setLabelType
            case RequestCode.RESPONSE_SET_LABEL_DENSITY:
                return Notification.Name.App.setLabelDensity
            case RequestCode.RESPONSE_SET_DIMENSION:
                return Notification.Name.App.setDimension
            default:
                return nil
            }
        }(packet.requestCode) else {
            return false
        }
        
        let result = packet.payload[0] != 0

        notify(name: name,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, result)))
        return true
    }
}
