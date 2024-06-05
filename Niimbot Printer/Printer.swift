//
//  Printer.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation
import os

class Printer {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Printer.self)
    )
    
    let packetDecoder = PacketDecoder(decoders: [SerialNumberPacketDecoder(),
                                                 SoftwareVersionPacketDecoder(),
                                                 HardwareVersionPacketDecoder(),
                                                 BatteryInformationPacketDecoder(),
                                                 DeviceTypePacketDecoder(),
                                                 RFIDDataPacketDecoder()])
    let printerDevice: PrinterDevice
    
    init(printerDevice: PrinterDevice) {
        self.printerDevice = printerDevice
    }
    
    func send(packet: Packet) {
        let downlink = packet.downlink()
        var c = try! self.printerDevice.downlink(from: downlink)
        Self.logger.info("Write \(c)")
    }
    
    public func getBatteryInformation() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.BATTERY.rawValue])
        send(packet: packet)
    }
    
    public func getDeviceType() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.DEVICE_TYPE.rawValue])
        send(packet: packet)
    }
    
    public func getHardwareVersion() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.HARDWARE_VERSION.rawValue])
        send(packet: packet)
    }
    
    public func getSoftwareVersion() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.SOFTWARE_VERSION.rawValue])
        send(packet: packet)
    }
    
    public func getSerialNumber() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.DEVICE_SERIAL.rawValue])
        send(packet: packet)
    }
    
    public func getRFIDData() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_RFID, data: [1])
        send(packet: packet)
    }
    

//case DENSITY = 1
//case PRINT_SPEED = 2
//case LABEL_TYPE = 3
//case LANGUAGE_TYPE = 6
//case AUTO_SHUTDOWN_TIME = 7

//case REQUEST_GET_INFO = 0x40
//case REQUEST_HEARTBEAT = 0xDC
//case REQUEST_SET_LABEL_TYPE = 0x23
//case REQUEST_SET_LABEL_DENSITY = 0x21
//case REQUEST_START_PRINT = 0x01
//case REQUEST_END_PRINT = 0xF3
//case REQUEST_START_PAGE_PRINT = 0x03
//case REQUEST_END_PAGE_PRINT = 0xE3
//case REQUEST_ALLOW_PRINT_CLEAR = 0x20
//case REQUEST_SET_DIMENSION = 0x13
//case REQUEST_SET_QUANTITY = 0x15
//case REQUEST_GET_PRINT_STATUS = 0xA3
// 
//    
//    
//case RESPONSE_GET_INFO_SOFTWARE_VERSION = 0x49 // RequestCode.REQUEST_GET_INFO + InfoCode.SOFTWARE_VERSION
//case RESPONSE_GET_INFO_DEVICE_SERIAL = 0x4B    // RequestCode.REQUEST_GET_INFO + InfoCode.DEVICE_SERIAL
//case RESPONSE_GET_INFO_HARDWARE_VERSION = 0x4C // RequestCode.REQUEST_GET_INFO + InfoCode.HARDWARE_VERSION
    
}
