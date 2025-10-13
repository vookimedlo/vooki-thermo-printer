//
//  UplinkProcessorTests.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.07.2024.
//

import XCTest
@testable import VookiThermoPrinter___D110

final class UplinkProcessorTests: XCTestCase {
    func testStartProcessingAndStopProcessing() {
        let io = StubbedIO()
        io.readResultThrows = false
        io.readOutputData = [1, 2]
        io.readResult = io.readOutputData.count
        let processor = UplinkProcessor(printerDevice: PrinterDevice(io: io))
        defer {
            processor.stopProcessing()
            XCTAssertTrue(processor.isCancelled)
        }
        XCTAssertFalse(processor.isExecuting)
        processor.startProcessing()
        sleep(1)
        XCTAssertTrue(processor.isExecuting)
        XCTAssertGreaterThan(io.readCalled, 1)
    }
    
    func testMain_PassesPacketsToDecoders() {
        var startPrintCount = 0
        var printStatusCount = 0
        
        let io = StubbedIO()
        io.readResultThrows = false
        io.readOutputData = [0x55, 0x55, 0x02, 0x01, 0x01, 0x02, 0xAA, 0xAA,
                             0x55, 0x55, 0xB3, 0x04, 0x00, 0x00, 0x02, 0x00, 0xB5, 0xAA, 0xAA]
        io.readOutputDataOnlyOnce = true
        io.readResult = io.readOutputData.count
        let processor = UplinkProcessor(printerDevice: PrinterDevice(io: io))
        defer {
            processor.stopProcessing()
            XCTAssertTrue(processor.isCancelled)
        }
        XCTAssertFalse(processor.isExecuting)
        processor.startProcessing()

        let handler: (Notification) -> Bool = { notification in
            guard let result = notification.userInfo?[Notification.Keys.packet] as? Packet else {
                return false
            }
            var exceptionResult: Bool = false
            
            switch (result.requestCode) {
            case .RESPONSE_START_PRINT:
                XCTAssertEqual(Packet(requestCode: .RESPONSE_START_PRINT, data: [1]), result)
                startPrintCount += 1
                break
            case .RESPONSE_GET_PRINT_STATUS:
                XCTAssertEqual(Packet(requestCode: .RESPONSE_GET_PRINT_STATUS,
                                      data: [0, 0, 2, 0]),
                               result)
                printStatusCount += 1
                exceptionResult = true
            default:
                break
            }
            return exceptionResult
        }

        let expectation = expectation(forNotification: .App.uplinkedPacket,
                                      object: nil,
                                      handler: handler)
        
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(io.readCalled, 0)

        XCTAssertEqual(1, startPrintCount)
        XCTAssertEqual(1, printStatusCount)
    }
}
