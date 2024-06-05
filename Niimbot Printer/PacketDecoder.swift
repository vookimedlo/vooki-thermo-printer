//
//  PacketDecoder.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation
import os

protocol PacketDecoding: Notifier {
    func decode(packet: Packet) -> Bool
}

class PacketDecoder: PacketDecoding, Observable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UplinkProcessor.self)
    )

    var decoders: [PacketDecoding]
    
    init(decoders: [PacketDecoding]) {
        self.decoders = decoders
        registerNotification(name: Notifications.Names.uplinkedPacket, selector: #selector(receiveNotification))
    }
    
    func decode(packet: Packet) -> Bool {
        for decoder in decoders {
            if decoder.decode(packet: packet) {
                return true
            }
        }
        return false
    }
    
    @objc func receiveNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        if Notifications.Names.uplinkedPacket ==  notification.name {
            let packet = notification.userInfo?[Notifications.Keys.packet] as! Packet
            guard decode(packet: packet) else {
                Self.logger.warning("Packet cannot be decoded")
                return
            }
        }
    }
}

class SerialNumberPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_SERIAL
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }

        notify(name: Notifications.Names.serialNumber,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, String(cString: packet.payload + [0]))))
        return true
    }
}


extension Array<UInt8> {
    func toUInt16(fromBigEndian: Bool = true) -> UInt16? {
        guard self.count == 2 else {
            return nil
        }
        return fromBigEndian ? ((UInt16(self[0]) << 8) + UInt16(self[1])) : ((UInt16(self[1]) << 8) + UInt16(self[0]))
    }
}

extension Data {
    func toUInt16(fromBigEndian: Bool = true) -> UInt16? {
        guard self.count == 2 else {
            return nil
        }
        return fromBigEndian ? ((UInt16(self[startIndex]) << 8) + UInt16(self[startIndex + 1])) : ((UInt16(self[startIndex + 1]) << 8) + UInt16(self[startIndex]))
    }
}

class SoftwareVersionPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_SOFTWARE_VERSION
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let integerVersion = packet.payload.toUInt16() else {
            return false
        }
        
        let version: Float = Float(integerVersion) / 100

        notify(name: Notifications.Names.softwareVersion,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, version)))
        return true
    }
}

class HardwareVersionPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_HARDWARE_VERSION
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let integerVersion = packet.payload.toUInt16() else {
            return false
        }
        
        let version: Float = Float(integerVersion) / 100

        notify(name: Notifications.Names.hardwareVersion,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, version)))
        return true
    }
}

class BatteryInformationPacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_BATTERY
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard packet.payload.count == 1 else {
            return false
        }

        notify(name: Notifications.Names.batteryInformation,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, packet.payload[0])))
        return true
    }
}

class DeviceTypePacketDecoder: PacketDecoding {
    static let code = RequestCode.RESPONSE_GET_INFO_DEVICE_TYPE
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard let deviceType = packet.payload.toUInt16() else {
            return false
        }

        notify(name: Notifications.Names.deviceType,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, deviceType)))
        return true
    }
}

class RFIDDataPacketDecoder: PacketDecoding {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UplinkProcessor.self)
    )
    
    
    static let code = RequestCode.RESPONSE_GET_RFID
    
    func decode(packet: Packet) -> Bool {
        guard Self.code == packet.requestCode else {
            return false
        }
        guard packet.payload.count > 0 else {
            return false
        }
        
        if packet.payload[0] == 0 {
            notify(name: Notifications.Names.noPaper)
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
        notify(name: Notifications.Names.rfidData,
               userInfo: [String : Any](dictionaryLiteral: (Notifications.Keys.value, RFIDData(uuid: uuid,
                                                                                               barcode: String(cString: barcode + [0]),
                                                                                               serial: String(cString: serial + [0]),
                                                                                               totalLength: totalLength,
                                                                                               usedLength: usedLength,
                                                                                               type: type))))
        return true
    }
}

struct RFIDData {
    let uuid: [UInt8]
    let barcode: String
    let serial: String
    let totalLength: UInt16
    let usedLength: UInt16
    let type: UInt8
}
