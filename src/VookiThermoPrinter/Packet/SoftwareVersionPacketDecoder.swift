//
//  SoftwareVersionPacketDecoder.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 12.06.2024.
//

import Foundation

public class SoftwareVersionPacketDecoder: PacketDecoding {
    public static let code = RequestCode.RESPONSE_GET_INFO_SOFTWARE_VERSION
    
    public init() {}
    
    public func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let integerVersion = packet.payload.toUInt16() else {
            return false
        }
        
        let version: Float = Float(integerVersion) / 100

        notify(name: Notification.Name.App.softwareVersion,
               userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, version)))
        return true
    }
}
