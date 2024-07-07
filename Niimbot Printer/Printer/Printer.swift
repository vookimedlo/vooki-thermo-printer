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
    
    func send(packet: Packet) {
        let downlink = packet.downlink()
        let writtenBytes = try! self.printerDevice.downlink(from: downlink)
        Self.logger.debug("Write op: \(writtenBytes) bytes")
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
    
    public func getAutoShutdownTime() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.AUTO_SHUTDOWN_TIME.rawValue])
        send(packet: packet)
    }
    
    public func getDensity() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.DENSITY.rawValue])
        send(packet: packet)
    }
    
    public func getLabelType() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_INFO, data: [InfoCode.LABEL_TYPE.rawValue])
        send(packet: packet)
    }
        
    public func getRFIDData() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_RFID, data: [1])
        send(packet: packet)
    }
    
    public func startPrint() {
        let packet = Packet(requestCode: RequestCode.REQUEST_START_PRINT, data: [1])
        send(packet: packet)
    }
    
    public func endPrint() {
        let packet = Packet(requestCode: RequestCode.REQUEST_END_PRINT, data: [1])
        send(packet: packet)
    }
    
    public func startPagePrint() {
        let packet = Packet(requestCode: RequestCode.REQUEST_START_PAGE_PRINT, data: [1])
        send(packet: packet)
    }
    
    public func endPagePrint() {
        let packet = Packet(requestCode: RequestCode.REQUEST_END_PAGE_PRINT, data: [1])
        send(packet: packet)
    }
    
    public func allowPrintClear() {
        let packet = Packet(requestCode: RequestCode.REQUEST_ALLOW_PRINT_CLEAR, data: [1])
        send(packet: packet)
    }
    
    public func setLabelType(type: UInt8) {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_LABEL_TYPE, data: [type])
        send(packet: packet)
    }
    
    public func setLabelDensity(density: UInt8) {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_LABEL_DENSITY, data: [density])
        send(packet: packet)
    }
    
    public func setDimension(width: UInt16, height: UInt16) {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_DIMENSION,
                            data: width.bigEndian.bytes + height.bigEndian.bytes)
        send(packet: packet)
    }
    
    public func getPrintStatus() {
        let packet = Packet(requestCode: RequestCode.REQUEST_GET_PRINT_STATUS, data: [1])
        send(packet: packet)
    }

    public func setPrinterData(data: [UInt8]) {
        let packet = Packet(requestCode: RequestCode.REQUEST_SET_PRINTER_DATA,
                            data: data)
        send(packet: packet)
    }

//case REQUEST_HEARTBEAT = 0xDC
//case REQUEST_SET_QUANTITY = 0x15
 
}
