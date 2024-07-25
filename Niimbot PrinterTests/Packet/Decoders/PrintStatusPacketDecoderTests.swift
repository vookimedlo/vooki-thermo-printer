//
//  PrintStatusPacketDecoderTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 21.07.2024.
//

import XCTest
import Niimbot_Printer

final class PrintStatusPacketDecoderTests: XCTestCase {
    
    func testDecode_SuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        let packet = Packet(requestCode: .RESPONSE_GET_PRINT_STATUS, data: inputData)
        
        let handler: (Notification) -> Bool = { notification in
            guard let result = notification.userInfo?[Notification.Keys.value] as? PrintStatus else {
                return false
            }
            
            let expectedResult = PrintStatus(page: 0x0102, progress1: 0x03, progress2: 0x04)
            XCTAssertEqual(expectedResult, result)
            
            return true
        }
        
        expectation(forNotification: .App.getPrintStatus,
                    object: nil,
                    handler: handler)
        
        let decoder = PrintStatusPacketDecoder()
        let result = decoder.decode(packet: packet)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
        
    func testDecode_UnsuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01]
        let packet = Packet(requestCode: .RESPONSE_GET_PRINT_STATUS, data: inputData)
        
        let e = expectation(forNotification: .App.getPrintStatus,
                            object: nil,
                            handler: nil)
        e.isInverted = true
        
        let decoder = PrintStatusPacketDecoder()
        let result = decoder.decode(packet: packet)
        
        XCTAssertFalse(result)
        
        wait(for: [e], timeout: 1)
    }
}
