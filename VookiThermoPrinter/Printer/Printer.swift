//
//  Printer.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation
import os

@PrinterActor
final class Printer {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Printer.self)
    )

    let packetDecoder = PacketDecoder(decoders: [SerialNumberPacketDecoder(),
                                                 SoftwareVersionPacketDecoder(),
                                                 HardwareVersionPacketDecoder(),
                                                 BatteryInformationPacketDecoder(),
                                                 DeviceTypePacketDecoder(),
                                                 RFIDDataPacketDecoder(),
                                                 BoolBytePacketDecoder(),
                                                 AutoShutdownTimePacketDecoder(),
                                                 DensityPacketDecoder(),
                                                 LabelTypePacketDecoder(),
                                                 PrintStatusPacketDecoder()])
    let printerDevice: PrinterDevice
    
    init(printerDevice: PrinterDevice) {
        self.printerDevice = printerDevice
    }
    
    func send(packet: Packet) throws {
        let downlink = packet.downlink()
        let writtenBytes = try self.printerDevice.downlink(from: downlink)
        Self.logger.debug("Write op: \(writtenBytes) bytes")
    }
    
    public func getBatteryInformation() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.BATTERY.rawValue])
        try send(packet: packet)
    }
    
    public func getDeviceType() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.DEVICE_TYPE.rawValue])
        try send(packet: packet)
    }
    
    public func getHardwareVersion() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.HARDWARE_VERSION.rawValue])
        try send(packet: packet)
    }
    
    public func getSoftwareVersion() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.SOFTWARE_VERSION.rawValue])
        try send(packet: packet)
    }
    
    public func getSerialNumber() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.DEVICE_SERIAL.rawValue])
        try send(packet: packet)
    }
    
    public func getAutoShutdownTime() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.AUTO_SHUTDOWN_TIME.rawValue])
        try send(packet: packet)
    }
    
    public func getDensity() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.DENSITY.rawValue])
        try send(packet: packet)
    }
    
    public func getLabelType() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.LABEL_TYPE.rawValue])
        try send(packet: packet)
    }
        
    public func getRFIDData() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_RFID, data: [1])
        try send(packet: packet)
    }
    
    public func startPrint() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_START_PRINT, data: [1])
        try send(packet: packet)
    }

    public func startPrint(pagesCount: UInt16) throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_START_PRINT,
                            data: pagesCount.bigEndian.bytes + [0, 0, 0, 0, 0])
        try send(packet: packet)
    }
    
    public func endPrint() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_END_PRINT, data: [1])
        try send(packet: packet)
    }
    
    public func startPagePrint() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_START_PAGE_PRINT, data: [1])
        try send(packet: packet)
    }
    
    public func endPagePrint() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_END_PAGE_PRINT, data: [1])
        try send(packet: packet)
    }
    
    public func allowPrintClear() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_ALLOW_PRINT_CLEAR, data: [1])
        try send(packet: packet)
    }
    
    public func setLabelType(type: UInt8) throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_LABEL_TYPE, data: [type])
        try send(packet: packet)
    }
    
    public func setLabelDensity(density: UInt8) throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_LABEL_DENSITY, data: [density])
        try send(packet: packet)
    }
    
    public func setDimension(width: UInt16, height: UInt16) throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_DIMENSION,
                            data: width.bigEndian.bytes + height.bigEndian.bytes)
        try send(packet: packet)
    }
    
    public func setDimension(width: UInt16, height: UInt16, copiesCount: UInt16) throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_DIMENSION,
                            data: width.bigEndian.bytes + height.bigEndian.bytes + copiesCount.bigEndian.bytes)
        try send(packet: packet)
    }
    
    public func getPrintStatus() throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_PRINT_STATUS, data: [1])
        try send(packet: packet)
    }

    public func setPrinterData(data: [UInt8]) throws {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_PRINTER_DATA,
                            data: data)
        try send(packet: packet)
    }

//case REQUEST_HEARTBEAT = 0xDC
//case REQUEST_SET_QUANTITY = 0x15
 
}
