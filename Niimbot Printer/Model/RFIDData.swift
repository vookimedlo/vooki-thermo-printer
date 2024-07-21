//
//  RFIDData.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 21.07.2024.
//


public struct RFIDData: Sendable, Equatable {
    public init(uuid: [UInt8], barcode: String, serial: String, totalLength: UInt16, usedLength: UInt16, type: UInt8) {
        self.uuid = uuid
        self.barcode = barcode
        self.serial = serial
        self.totalLength = totalLength
        self.usedLength = usedLength
        self.type = type
    }

    let uuid: [UInt8]
    let barcode: String
    let serial: String
    let totalLength: UInt16
    let usedLength: UInt16
    let type: UInt8
}
