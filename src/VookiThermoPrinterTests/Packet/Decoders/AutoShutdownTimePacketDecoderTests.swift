/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import XCTest
@testable import VookiThermoPrinter___D110

final class AutoShutdownTimePacketDecoderTests: XCTestCase {
    
    func testDecode_SuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_AUTO_SHUTDOWN_TIME, data: inputData)
        
        let handler: (Notification) -> Bool = { notification in
            guard let result = notification.userInfo?[Notification.Keys.value] as? UInt8 else {
                return false
            }
            XCTAssertEqual(inputData[0], result)
            
            return true
        }
        
        expectation(forNotification: .App.autoShutdownTime,
                    object: nil,
                    handler: handler)
        
        let decoder = AutoShutdownTimePacketDecoder()
        let result = decoder.decode(packet: packet)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
        
    func testDecode_UnsuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01, 0x02]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_AUTO_SHUTDOWN_TIME, data: inputData)
        
        let e = expectation(forNotification: .App.autoShutdownTime,
                            object: nil,
                            handler: nil)
        e.isInverted = true
        
        let decoder = AutoShutdownTimePacketDecoder()
        let result = decoder.decode(packet: packet)
        
        XCTAssertFalse(result)
        
        wait(for: [e], timeout: 1)
    }
}

