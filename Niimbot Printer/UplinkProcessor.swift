//
//  UplinkProcessor.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 31.05.2024.
//

import Foundation
import os

class UplinkProcessor : Thread, Notifier {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UplinkProcessor.self)
    )
    
    let printerDevice: PrinterDevice
    
    init(printerDevice: PrinterDevice) {
        self.printerDevice = printerDevice
        super.init()
    }
    
    func startProcessing() {
        super.start()
    }
    
    func stopProcessing(){
        super.cancel()
    }
        
    override func main() {
        defer {
            Self.logger.info("Processing thread finished")
        }
        Self.logger.info("Processing thread started")
        var data = Data(capacity: 64)
        while !super.isCancelled {
            Self.logger.info("Processing thread looped")
            let uplink = try! printerDevice.uplink(ofLength: 1)
            data.append(contentsOf: uplink)
            Self.logger.info("\(data.hexEncodedString(options: [.commaSeparator, .prefix, .upperCase]))")

            if let packet = Packet.create(fromStream: &data) {
                notify(name: Notifications.Names.uplinkedPacket,
                       userInfo: [String : Packet](dictionaryLiteral: (Notifications.Keys.packet, packet)))
            }
        }
    }
}
