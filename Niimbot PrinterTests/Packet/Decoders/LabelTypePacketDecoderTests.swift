//
//  LabelTypePacketDecoderTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 21.07.2024.
//

import XCTest
import Niimbot_Printer

final class LabelTypePacketDecoderTests: XCTestCase {
    
    func testDecode_SuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_LABEL_TYPE, data: inputData)
        
        let handler: (Notification) -> Bool = { notification in
            guard let result = notification.userInfo?[Notification.Keys.value] as? UInt8 else {
                return false
            }
            XCTAssertEqual(inputData[0], result)
            
            return true
        }
        
        expectation(forNotification: .App.labelType,
                    object: nil,
                    handler: handler)
        
        let decoder = LabelTypePacketDecoder()
        let result = decoder.decode(packet: packet)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
        
    func testDecode_UnsuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01, 0x02]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_LABEL_TYPE, data: inputData)
        
        let e = expectation(forNotification: .App.labelType,
                            object: nil,
                            handler: nil)
        e.isInverted = true
        
        let decoder = LabelTypePacketDecoder()
        let result = decoder.decode(packet: packet)
        
        XCTAssertFalse(result)
        
        wait(for: [e], timeout: 1)
    }
}
