//
//  SerialNumberPacketDecoderTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 21.07.2024.
//


//
//  DensityPacketDecoderTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 21.07.2024.
//

import XCTest
@testable import VookiThermoPrinter

final class SerialNumberPacketDecoderTests: XCTestCase {
    
    func testDecode_SuccessfulDecoding() throws {
        let inputData: [UInt8] = [0x54, 0x65, 0x73, 0x74]
        let packet = Packet(requestCode: .RESPONSE_GET_INFO_DEVICE_SERIAL, data: inputData)
        
        let handler: (Notification) -> Bool = { notification in
            guard let result = notification.userInfo?[Notification.Keys.value] as? String else {
                return false
            }
            XCTAssertEqual("Test", result)
            
            return true
        }
        
        expectation(forNotification: .App.serialNumber,
                    object: nil,
                    handler: handler)
        
        let decoder = SerialNumberPacketDecoder()
        let result = decoder.decode(packet: packet)
        XCTAssertTrue(result)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
