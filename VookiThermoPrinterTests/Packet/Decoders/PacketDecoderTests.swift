/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import XCTest
@testable import VookiThermoPrinter___D110

final class PacketDecoderTests: XCTestCase {
    func testDecode_Fails() {
        let decoder = PacketDecoder(decoders: [DeviceTypePacketDecoder()])
        let result = decoder.decode(packet: Packet(requestCode: .RESPONSE_END_PRINT, data: [1]))
        XCTAssertFalse(result)
    }
    
    func testDecode_Succeed() {
        let decoder = PacketDecoder(decoders: [DeviceTypePacketDecoder(), BoolBytePacketDecoder()])
        let result = decoder.decode(packet: Packet(requestCode: .RESPONSE_END_PRINT, data: [1]))
        XCTAssertTrue(result)
    }
    
    func testDecode_SucceedViaNotification() {
        let exceptation = XCTNSNotificationExpectation(name: .App.endPrint)

        // Do not replace decoder with _ otherwise it will be discarded before the test finishes
        let decoder = PacketDecoder(decoders: [DeviceTypePacketDecoder(), BoolBytePacketDecoder()])

        NotificationCenter.default.post(name: Notification.Name.App.uplinkedPacket,
                                        object: nil,
                                        userInfo: [String : Packet](dictionaryLiteral: (Notification.Keys.packet, Packet(requestCode: .RESPONSE_END_PRINT, data: [1]))))
        
        wait(for: [exceptation], timeout: 1)
    }
    
    func testDecode_FailedViaNotification() {
        let exceptation = XCTNSNotificationExpectation(name: .App.endPrint)
        exceptation.isInverted = true

        // Do not replace decoder with _ otherwise it will be discarded before the test finishes
        let decoder = PacketDecoder(decoders: [DeviceTypePacketDecoder()])

        NotificationCenter.default.post(name: Notification.Name.App.uplinkedPacket,
                                        object: nil,
                                        userInfo: [String : Packet](dictionaryLiteral: (Notification.Keys.packet, Packet(requestCode: .RESPONSE_END_PRINT, data: [1]))))
        
        wait(for: [exceptation], timeout: 1)
    }
}

