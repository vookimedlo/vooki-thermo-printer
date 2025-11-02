/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public class DeviceTypePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_TYPE
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let deviceType = packet.payload.toUInt16() else {
            return false
        }

        notify(name: Notification.Name.App.deviceType,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, deviceType)))
        return true
    }
}
