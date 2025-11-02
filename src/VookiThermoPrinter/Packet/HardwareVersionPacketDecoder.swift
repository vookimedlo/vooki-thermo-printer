/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public class HardwareVersionPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_HARDWARE_VERSION
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let integerVersion = packet.payload.toUInt16() else {
            return false
        }
        
        let version: Float = Float(integerVersion) / 100

        notify(name: Notification.Name.App.hardwareVersion,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, version)))
        return true
    }
}
