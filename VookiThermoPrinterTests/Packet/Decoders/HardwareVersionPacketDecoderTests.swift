//
//  HardwareVersionPacketDecoderTests.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 21.07.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110

final class HardwareVersionPacketDecoderTests: XCTestCase {
    
    func testDecode_SuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01, 0x02]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_HARDWARE_VERSION, data: inputData)
        
        let handler: (Notification) -> Bool = { notification in
            guard let result = notification.userInfo?[Notification.Keys.value] as? Float else {
                return false
            }
            XCTAssertEqual(2.58, result)
            
            return true
        }
        
        expectation(forNotification: .App.hardwareVersion,
                    object: nil,
                    handler: handler)
        
        let decoder = HardwareVersionPacketDecoder()
        let result = decoder.decode(packet: packet)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
        
    func testDecode_UnsuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x01]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_SOFTWARE_VERSION, data: inputData)
        
        let e = expectation(forNotification: .App.hardwareVersion,
                            object: nil,
                            handler: nil)
        e.isInverted = true
        
        let decoder = SoftwareVersionPacketDecoder()
        let result = decoder.decode(packet: packet)
        
        XCTAssertFalse(result)
        
        wait(for: [e], timeout: 1)
    }
}
