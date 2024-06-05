//
//  Packet.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import Foundation
import os

public enum InfoCode: UInt8 {
    case DENSITY = 1
    case PRINT_SPEED = 2
    case LABEL_TYPE = 3
    case LANGUAGE_TYPE = 6
    case AUTO_SHUTDOWN_TIME = 7
    case DEVICE_TYPE = 8
    case SOFTWARE_VERSION = 9
    case BATTERY = 10
    case DEVICE_SERIAL = 11
    case HARDWARE_VERSION = 12
}

public enum RequestCode: UInt8 {
    case REQUEST_GET_INFO = 0x40
    case REQUEST_GET_RFID = 0x1A
    case REQUEST_HEARTBEAT = 0xDC
    case REQUEST_SET_LABEL_TYPE = 0x23
    case REQUEST_SET_LABEL_DENSITY = 0x21
    case REQUEST_START_PRINT = 0x01
    case REQUEST_END_PRINT = 0xF3
    case REQUEST_START_PAGE_PRINT = 0x03
    case REQUEST_END_PAGE_PRINT = 0xE3
    case REQUEST_ALLOW_PRINT_CLEAR = 0x20
    case REQUEST_SET_DIMENSION = 0x13
    case REQUEST_SET_QUANTITY = 0x15
    case REQUEST_GET_PRINT_STATUS = 0xA3
    
    case RESPONSE_GET_INFO_DEVICE_TYPE = 0x48      // RequestCode.REQUEST_GET_INFO + InfoCode.DEVICE_TYPE
    case RESPONSE_GET_INFO_SOFTWARE_VERSION = 0x49 // RequestCode.REQUEST_GET_INFO + InfoCode.SOFTWARE_VERSION
    case RESPONSE_GET_INFO_BATTERY = 0x4A          // RequestCode.REQUEST_GET_INFO + InfoCode.BATTERY
    case RESPONSE_GET_INFO_DEVICE_SERIAL = 0x4B    // RequestCode.REQUEST_GET_INFO + InfoCode.DEVICE_SERIAL
    case RESPONSE_GET_INFO_HARDWARE_VERSION = 0x4C // RequestCode.REQUEST_GET_INFO + InfoCode.HARDWARE_VERSION
    case RESPONSE_GET_RFID = 0x1B                  // RequestCode.GET_RFID + 1
}

public class Packet {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Packet.self)
    )
    
    public private(set) var requestCode: RequestCode
    public private(set) var payload: [UInt8]
    
    public init(requestCode: RequestCode, data: ArraySlice<UInt8>) {
        self.requestCode = requestCode
        self.payload = [UInt8](data)
    }
    
    private static func checksum(requestCode: RequestCode, payload: ArraySlice<UInt8>) -> UInt8 {
        var checksum = requestCode.rawValue ^ UInt8(payload.count)
        for i in payload {
            checksum ^= i
        }
        return checksum
    }
    
    public func downlink() -> [UInt8] {
        let payloadChecksum = Packet.checksum(requestCode: requestCode, payload: payload[...])
        return [0x55, 0x55, self.requestCode.rawValue, UInt8(payload.count)] + payload + [payloadChecksum, 0xAA, 0xAA]
    }
    
    
}

extension Packet {
    public static func create(uplink: ArraySlice<UInt8>) -> Packet? {
        guard uplink.count > 6 else {
            return nil
        }
        guard (uplink.starts(with: [0x55, 0x55]) && uplink.suffix(2) == [UInt8](arrayLiteral: 0xAA, 0xAA)[...]) else {
            return nil
        }
        
        let rawRequestCode = uplink[2]
        
        guard let requestCode = RequestCode(rawValue: rawRequestCode) else {
            return nil
        }
        
        let payloadLength = uplink[3]
        let payload = uplink[4..<4 + Int(payloadLength)]
        let payloadChecksum = checksum(requestCode: requestCode, payload: payload)
        
        guard payloadChecksum == uplink[uplink.count - 3] else {
            return nil
        }

        return Packet(requestCode: requestCode, data: payload)
    }
}

extension Packet {
    public static func create(fromStream data: inout Data) -> Packet? {
        if data.count > 6 && data.starts(with: [UInt8](arrayLiteral: 0x55, 0x55)) {
            let payloadSize = data[data.startIndex + 3]
            if data.count >= 4 + payloadSize + 3 && data[data.startIndex + 4 + Int(payloadSize) + 1] == 0xAA && data[data.startIndex + 4 + Int(payloadSize) + 2] == 0xAA {
                let packetSize = 4 + Int(payloadSize) + 3
                var packetArray = Array<UInt8>(repeating: 0, count: packetSize)
                _ = packetArray.withUnsafeMutableBytes { data.copyBytes(to: $0) }
                defer {
                    data.removeFirst(packetSize)
                }
                
                if let packet = Self.create(uplink: packetArray[...]) {
                    return packet
                }
                else {
                    Self.logger.error("Internal error: cannot parse the uplinked packet")
                }
            }
        }
        return nil
    }
}
