/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import XCTest
@testable import VookiThermoPrinter___D110

final class BoolBytePacketDecoderTests: XCTestCase {
    
    private func translate(code: RequestCode) -> NSNotification.Name? {
        switch code {
        case RequestCode.RESPONSE_START_PRINT:
            return Notification.Name.App.startPrint
        case RequestCode.RESPONSE_END_PRINT:
            return Notification.Name.App.endPrint
        case RequestCode.RESPONSE_START_PAGE_PRINT:
            return Notification.Name.App.startPagePrint
        case RequestCode.RESPONSE_END_PAGE_PRINT:
            return Notification.Name.App.endPagePrint
        case RequestCode.RESPONSE_ALLOW_PRINT_CLEAR:
            return Notification.Name.App.allowPrintClear
        case RequestCode.RESPONSE_SET_LABEL_TYPE:
            return Notification.Name.App.setLabelType
        case RequestCode.RESPONSE_SET_LABEL_DENSITY:
            return Notification.Name.App.setLabelDensity
        case RequestCode.RESPONSE_SET_DIMENSION:
            return Notification.Name.App.setDimension
        default:
            return nil
        }
    }

    func testBoolByteDecoder_SuccessfulDecoding_True() throws {
        let inputData: [UInt8] = [0x01]
        
        for code in BoolBytePacketDecoder.codes {
            let packet = Packet(requestCode: code, data: inputData)
            
            let handler: (Notification) -> Bool = { notification in
                guard let result = notification.userInfo?[Notification.Keys.value] as? Bool else {
                    return false
                }
                XCTAssertTrue(result)
                return true
            }
            
            let name = try XCTUnwrap(translate(code: code))

            expectation(forNotification: name,
                        object: nil,
                        handler: handler)
            
            let decoder = BoolBytePacketDecoder()
            let result = decoder.decode(packet: packet)
            XCTAssertTrue(result)
            
            waitForExpectations(timeout: 1, handler: nil)
        }
    }
    
    func testBoolByteDecoder_SuccessfulDecoding_False() throws {
        let inputData: [UInt8] = [0x00]
        
        for code in BoolBytePacketDecoder.codes {
            let packet = Packet(requestCode: code, data: inputData)
            
            let handler: (Notification) -> Bool = { notification in
                guard let result = notification.userInfo?[Notification.Keys.value] as? Bool else {
                    return false
                }
                XCTAssertFalse(result)
                return true
            }
            
            let name = try XCTUnwrap(translate(code: code))

            expectation(forNotification: name,
                        object: nil,
                        handler: handler)
            
            let decoder = BoolBytePacketDecoder()
            let result = decoder.decode(packet: packet)
            XCTAssertTrue(result)
            
            waitForExpectations(timeout: 1, handler: nil)
        }
    }
    
    func testBoolByteDecoder_UnsuccessfulDecoding2bytes() throws {
        let inputData: [UInt8] = [0x01, 0x02]
        
        for code in BoolBytePacketDecoder.codes.filter({ $0 != RequestCode.RESPONSE_SET_DIMENSION }) {
            let packet = Packet(requestCode: code, data: inputData)
            
            let name = try XCTUnwrap(translate(code: code))

            let e = expectation(forNotification: name,
                        object: nil,
                        handler: nil)
            e.isInverted = true
            
            let decoder = BoolBytePacketDecoder()
            let result = decoder.decode(packet: packet)
            
            XCTAssertFalse(result)
            
            wait(for: [e], timeout: 1)
        }
    }
    
    func testBoolByteDecoder_UnsuccessfulDecoding3bytes() throws {
        let inputData: [UInt8] = [0x01, 0x02, 0x03]
        
        for code in BoolBytePacketDecoder.codes {
            let packet = Packet(requestCode: code, data: inputData)
            
            let name = try XCTUnwrap(translate(code: code))

            let e = expectation(forNotification: name,
                        object: nil,
                        handler: nil)
            e.isInverted = true
            
            let decoder = BoolBytePacketDecoder()
            let result = decoder.decode(packet: packet)
            
            XCTAssertFalse(result)
            
            wait(for: [e], timeout: 1)
        }
    }
}

