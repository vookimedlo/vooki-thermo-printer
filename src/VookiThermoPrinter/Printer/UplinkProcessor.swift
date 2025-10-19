/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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
