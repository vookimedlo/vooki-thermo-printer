/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2025 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public class PrinterCheckLinePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_PRINTER_CHECK_LINE
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard packet.payload.count == 3 else {
            return false
        }
        
        var data = Data(bytes: packet.payload, count: packet.payload.count)
        
        let uint16Size = UInt16.bitWidth / 8
        let lineNumber = [UInt8](data[data.startIndex..<data.startIndex + uint16Size]).toUInt16()!
        data.removeFirst(uint16Size)

        let something = data.removeFirst()

        notify(name: Notification.Name.App.printerCheckLine,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, PrinterCheckLine(lineNumber: lineNumber,
                                                                                                           something: something))))
        return true
    }
}
