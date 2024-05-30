//
//  FileSystemIO.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation

public class FileSystemIO : IO {
    var fileDescriptor: Int32?
    let filepath: String
    
    public init(filepath: String) {
        self.filepath = filepath
    }
    
    public func open() throws {
        if fileDescriptor != nil {
            close()
        }
        
        fileDescriptor = Darwin.open(self.filepath, O_RDWR | O_NOCTTY)
        if fileDescriptor == -1 { throw IOError.open }
    }
    
    public func close() {
        guard let fileDescriptor = fileDescriptor else {
            return
        }
        
        Darwin.close(fileDescriptor)
    }
    
    public func readBytes(into buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw IOError.read
        }
        let bytesRead = Darwin.read(fileDescriptor, buffer, size)
        if bytesRead == -1 { throw IOError.read }
        return bytesRead
    }
    
    public func writeBytes(from buffer: UnsafeRawPointer, size: Int) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw IOError.write
        }
        let bytesWritten = Darwin.write(fileDescriptor, buffer, size)
        if bytesWritten == -1 { throw IOError.write }
        return bytesWritten
    }
    
    
}
