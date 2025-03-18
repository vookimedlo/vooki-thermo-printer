//
//  UplinkProcessor.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 31.05.2024.
//

import Foundation
import os

public class UplinkProcessor : Thread, Notifiable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UplinkProcessor.self)
    )
    
    private let printerDevice: PrinterDevice
    
    public init(printerDevice: PrinterDevice) {
        self.printerDevice = printerDevice
        super.init()
    }
    
    public func startProcessing() {
        super.start()
    }
    
    public func stopProcessing(){
        super.cancel()
    }
        
    public override func main() {
        defer {
            Self.logger.info("Processing thread finished")
        }
        Self.logger.info("Processing thread started")
        let blockSize = 64
        var data = Data(capacity: blockSize)
        while !super.isCancelled {
            Self.logger.info("Processing thread looped")
            let uplink = try! printerDevice.uplink(ofLength: blockSize)
            data.append(contentsOf: uplink)
            Self.logger.info("\(data.hexEncodedString(options: [.commaSeparator, .prefix, .upperCase]))")

            if let packet = Packet.create(fromStream: &data) {
                notify(name: Notification.Name.App.uplinkedPacket,
                       userInfo: [String : Packet](dictionaryLiteral: (Notification.Keys.packet, packet)))
            }
        }
    }
}
