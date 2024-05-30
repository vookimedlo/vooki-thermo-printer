//
//  Packet.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import Foundation

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
    case GET_INFO = 0x40
    case GET_RFID = 0x1A
    case HEARTBEAT = 0xDC
    case SET_LABEL_TYPE = 0x23
    case SET_LABEL_DENSITY = 0x21
    case START_PRINT = 0x01
    case END_PRINT = 0xF3
    case START_PAGE_PRINT = 0x03
    case END_PAGE_PRINT = 0xE3
    case ALLOW_PRINT_CLEAR = 0x20
    case SET_DIMENSION = 0x13
    case SET_QUANTITY = 0x15
    case GET_PRINT_STATUS = 0xA3
}


//public enum ResponseCode: UInt8 {
//    case GET_INFO_SOFTWARE_VERSION = RequestCode.GET_INFO + InfoCode.SOFTWARE_VERSION
//    case GET_INFO_HARDWARE_VERSION = RequestCode.GET_INFO + InfoCode.HARDWARE_VERSION
//    case GET_INFO_DEVICE_SERIAL = RequestCode.GET_INFO + InfoCode.DEVICE_SERIAL
//}


public class Packet {
    public private(set) var requestCode: RequestCode
    public private(set) var payload: [UInt8]
    
    public init(requestCode: RequestCode, data: [UInt8]) {
        self.requestCode = requestCode
        self.payload = data
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
    public static func create(uplink: [UInt8]) -> Packet? {
        guard uplink.count > 6 else {
            return nil
        }
        guard (uplink.prefix(2) == [UInt8](arrayLiteral: 0x55, 0x55)[...] && uplink.suffix(2) == [UInt8](arrayLiteral: 0xAA, 0xAA)[...]) else {
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

        return Packet(requestCode: requestCode, data: [UInt8](payload))
    }
}
