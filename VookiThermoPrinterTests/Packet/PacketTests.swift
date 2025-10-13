//
//  PacketTests.swift
//  Niimbot PrinterTests
//
//  Created by Michal Duda on 28.05.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110

final class PacketTests: XCTestCase {
    
    static let validDownlinks: [[UInt8]] = [
        [0x55, 0x55, RequestCode.REQUEST_GET_INFO.rawValue, 0x03, 0x11, 0x22, 0x33, 0x43, 0xAA, 0xAA],
        [0x55, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0xB3, 0xAA, 0xAA],
        [0x55, 0x55, RequestCode.REQUEST_GET_RFID.rawValue, 0x00, RequestCode.REQUEST_GET_RFID.rawValue, 0xAA, 0xAA]
    ]
    
    static let validUplinks: [[UInt8]] = validDownlinks
    
    static let validPackets: [(RequestCode, [UInt8])] = [
        (RequestCode.REQUEST_GET_INFO, [0x11, 0x22, 0x33]),
        (RequestCode.REQUEST_GET_PRINT_STATUS, [0x11]),
        (RequestCode.REQUEST_GET_RFID, [])
    ]
    
    func testPacketConstructors() {
        let inputData = [0x55, 0x55, RequestCode.REQUEST_GET_INFO.rawValue, 0x03, 0x11, 0x22, 0x33, 0x43, 0xAA, 0xAA]
        
        let fromArray = Packet(requestCode: .REQUEST_GET_INFO, data: inputData)
        let fromSlice = Packet(requestCode: .REQUEST_GET_INFO, data: inputData[...])
        
        XCTAssertEqual(fromArray.payload, fromSlice.payload)
        XCTAssertEqual(fromArray.requestCode, fromSlice.requestCode)
    }
    
    func testDownlinkConstructionFromPacket() {
        
        for index in 0...PacketTests.validPackets.count - 1 {
            let packet = Packet(requestCode: PacketTests.validPackets[index].0, data: PacketTests.validPackets[index].1[...])
            let downlink = packet.downlink()
            let expectedDownlink = PacketTests.validDownlinks[index]
            XCTAssertEqual(expectedDownlink, downlink)
        }
    }
    
    func testPacketConstructionFromUplink() throws {
        for index in 0...PacketTests.validUplinks.count - 1 {
            let packet = try XCTUnwrap(Packet.create(uplink: PacketTests.validUplinks[index][...]))
            let (expectedRequestCode, expectedPayload) = PacketTests.validPackets[index]
            XCTAssertEqual(expectedRequestCode, packet.requestCode)
            XCTAssertEqual(expectedPayload, packet.payload)
        }
    }
    
    func testPacketConstructionFromUplink_InvalidUplinkSize() {
        let packet = Packet.create(uplink: [0x55, 0x55, 0x11, 0x12, 0xAA, 0xAA])
        XCTAssertNil(packet)
    }
    
    func testPacketConstructionFromUplink_InvalidStartSequence() {
        let packet = Packet.create(uplink:  [0x55, 0x56, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0xB3, 0xAA, 0xAA])
        XCTAssertNil(packet)
        
        let packet2 = Packet.create(uplink:  [0x56, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0xB3, 0xAA, 0xAA])
        XCTAssertNil(packet2)
    }
    
    func testPacketConstructionFromUplink_InvalidEndSequence() {
        let packet = Packet.create(uplink:  [0x55, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0xB3, 0xAA, 0xAB])
        XCTAssertNil(packet)
        
        let packet2 = Packet.create(uplink:  [0x55, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0xB3, 0xAB, 0xAA])
        XCTAssertNil(packet2)
    }
    
    func testPacketConstructionFromUplink_InvalidCheksum() {
        let packet = Packet.create(uplink:  [0x55, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0x00, 0xAA, 0xAA])
        XCTAssertNil(packet)
    }
    
    func testPacketConstructionFromUplink_InvalidRequestCode() {
        let packet = Packet.create(uplink:  [0x55, 0x55, 0x00, 0x01, 0x11, 0xB3, 0xAA, 0xAA])
        XCTAssertNil(packet)
    }

    func testPacketConstructionFromUplink_InvalidPayloadLength() {
        let packet = Packet.create(uplink:  [0x55, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x02, 0x11, 0xB3, 0xAA, 0xAA])
        XCTAssertNil(packet)
    }
    
    func testPacketConstructionFromUplinkStream() throws {
        var stream = Data()
        for uplink in PacketTests.validUplinks {
            stream.append(contentsOf: uplink)
        }
        for index in 0 ..< PacketTests.validUplinks.count {
            let packet =  try XCTUnwrap(Packet.create(fromStream: &stream))
            let (expectedRequestCode, expectedPayload) = PacketTests.validPackets[index]
            XCTAssertEqual(expectedRequestCode, packet.requestCode)
            XCTAssertEqual(expectedPayload, packet.payload)
        }
        XCTAssertTrue(stream.isEmpty)
    }

    func testPacketConstructionFromUplinkStream_InvalidData() throws {
        var stream = Data()
        for uplink in PacketTests.validUplinks {
            stream.append(contentsOf: uplink)
        }
        stream.append(contentsOf: [0x00])
        for uplink in PacketTests.validUplinks {
            stream.append(contentsOf: uplink)
        }
        
        var expectedRemainingStream = Data()
        for uplink in PacketTests.validUplinks {
            expectedRemainingStream.append(contentsOf: uplink)
        }
        expectedRemainingStream.append(contentsOf: [0x00])
        
        for index in 0 ..< PacketTests.validUplinks.count {
            let packet =  try XCTUnwrap(Packet.create(fromStream: &stream))
            let (expectedRequestCode, expectedPayload) = PacketTests.validPackets[index]
            XCTAssertEqual(expectedRequestCode, packet.requestCode)
            XCTAssertEqual(expectedPayload, packet.payload)
        }
        
        XCTAssertNil(Packet.create(fromStream: &stream))
        XCTAssertFalse(stream.isEmpty)
        
        var streamBuffer = [UInt8]()
        streamBuffer.reserveCapacity(stream.count)
        _ = streamBuffer.withUnsafeMutableBytes{stream.copyBytes(to: $0)}
        
        var expectedRemainingStreamBuffer = [UInt8]()
        expectedRemainingStreamBuffer.reserveCapacity(expectedRemainingStream.count)
        _ = expectedRemainingStreamBuffer.withUnsafeMutableBytes{expectedRemainingStream.copyBytes(to: $0)}
        
        XCTAssertEqual(expectedRemainingStreamBuffer, streamBuffer)
    }

    func testPacketConstructionFromUplinkStream_InvalidCheksum() throws {
        var stream = Data()
        stream.append(contentsOf: [0x55, 0x55, RequestCode.REQUEST_GET_PRINT_STATUS.rawValue, 0x01, 0x11, 0x00, 0xAA, 0xAA])
        
        XCTAssertNil(Packet.create(fromStream: &stream))
        XCTAssertTrue(stream.isEmpty)
    }
    
}
