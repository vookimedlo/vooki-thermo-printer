/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import XCTest
@testable import VookiThermoPrinter___D110

final class FileSystemIOTests: XCTestCase {
    func testOpenFailesAndThrows() throws {
        let stubbedFileSystem = StubbedFileSystem()
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        XCTAssertThrowsError(try fileSystemIO.open()) { error in
            XCTAssertEqual(error as! IOError, IOError.open)
        }
        XCTAssertEqual(1, stubbedFileSystem.openCalled)
    }
    
    func testReadFailesAndThrows() throws {
        var buffer: [UInt8] = []
        let stubbedFileSystem = StubbedFileSystem()
        stubbedFileSystem.openResult = 1
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        
        XCTAssertNoThrow(try fileSystemIO.open())
        
        XCTAssertThrowsError(try fileSystemIO.readBytes(into: &buffer, size: 0)) { error in
            XCTAssertEqual(error as! IOError, IOError.read)
        }
        XCTAssertEqual(1, stubbedFileSystem.readCalled)
    }
    
    func testWriteFailesAndThrows() throws {
        var buffer: [UInt8] = []
        let stubbedFileSystem = StubbedFileSystem()
        stubbedFileSystem.openResult = 1
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        
        XCTAssertNoThrow(try fileSystemIO.open())

        XCTAssertThrowsError(try fileSystemIO.writeBytes(from: &buffer, size: 0)) { error in
            XCTAssertEqual(error as! IOError, IOError.write)
        }
        XCTAssertEqual(1, stubbedFileSystem.writeCalled)
    }
    
    func testOpenClosesFileDescriptorIfAlreadyOpenedAndOpensAgain() throws {
        let stubbedFileSystem = StubbedFileSystem()
        stubbedFileSystem.openResult = 1
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        XCTAssertNoThrow(try fileSystemIO.open())
        XCTAssertEqual(1, stubbedFileSystem.openCalled)
        XCTAssertEqual(0, stubbedFileSystem.closeCalled)
        XCTAssertNoThrow(try fileSystemIO.open())
        XCTAssertEqual(2, stubbedFileSystem.openCalled)
        XCTAssertEqual(1, stubbedFileSystem.closeCalled)
    }
    
    func testCloseDoesNothingIfFileDescriptorIfNotOpened() throws {
        let stubbedFileSystem = StubbedFileSystem()
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        fileSystemIO.close()
        XCTAssertEqual(0, stubbedFileSystem.closeCalled)
    }
    
    func testReadDoesNothingAndThrowsIfFileDescriptorIfNotOpened() throws {
        var buffer: [UInt8] = []
        let stubbedFileSystem = StubbedFileSystem()
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        XCTAssertThrowsError(try fileSystemIO.readBytes(into: &buffer, size: 0)) { error in
            XCTAssertEqual(error as! IOError, IOError.read)
        }
        XCTAssertEqual(0, stubbedFileSystem.readCalled)
    }
    
    func testWriteDoesNothingAndThrowsIfFileDescriptorIfNotOpened() throws {
        var buffer: [UInt8] = []
        let stubbedFileSystem = StubbedFileSystem()
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        
        XCTAssertThrowsError(try fileSystemIO.writeBytes(from: &buffer, size: 0)) { error in
            XCTAssertEqual(error as! IOError, IOError.write)
        }
        XCTAssertEqual(0, stubbedFileSystem.writeCalled)
    }
    
    func testReadSuccessfullyProcessedInputData() throws {
        var buffer: [UInt8] = [0xAA,0xBB]
        let stubbedFileSystem = StubbedFileSystem()
        stubbedFileSystem.openResult = 1
        stubbedFileSystem.readResult = buffer.count
        stubbedFileSystem.readOutputData = [0x12,0x34]
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        XCTAssertNoThrow(try fileSystemIO.open())
        
        let result = try fileSystemIO.readBytes(into: &buffer, size: buffer.count)
        XCTAssertEqual(1, stubbedFileSystem.readCalled)
        XCTAssertEqual(2, result)
        XCTAssertEqual(stubbedFileSystem.readOutputData, buffer)
    }
    
    func testWriteSuccessfullyProcessedInputData() throws {
        var buffer: [UInt8] = [1,2]
        let stubbedFileSystem = StubbedFileSystem()
        stubbedFileSystem.openResult = 1
        stubbedFileSystem.writeResult = buffer.count
        let fileSystemIO = FileSystemIO(fileSystemAccess: stubbedFileSystem, filepath: "testing")
        XCTAssertNoThrow(try fileSystemIO.open())

        let result = try fileSystemIO.writeBytes(from: &buffer, size: buffer.count)
        XCTAssertEqual(1, stubbedFileSystem.writeCalled)
        XCTAssertEqual(2, result)
        XCTAssertEqual(buffer, stubbedFileSystem.writeInputBuffer)
    }
}

