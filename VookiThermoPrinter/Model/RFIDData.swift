//
//  RFIDData.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 21.07.2024.
//


struct RFIDData: Sendable, Equatable {
    let uuid: [UInt8]
    let barcode: String
    let serial: String
    let totalLength: UInt16
    let usedLength: UInt16
    let type: UInt8
}
