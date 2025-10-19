//
//  PosixFileSystem.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation

public class PosixFileSystemAccess : FileSystemAccess {
    public func open(_ path: UnsafePointer<CChar>, _ oflag: Int32) -> Int32 {
        return Darwin.open(path, oflag | O_NONBLOCK)
    }
    
    @discardableResult
    public func close(_ fileDescriptor: Int32) -> Int32 {
        return Darwin.close(fileDescriptor)
    }
    
    public func read(_ fileDescriptor: Int32, _ buffer: UnsafeMutableRawPointer!, _ count: Int) -> Int {
       
        var pollfd = Darwin.pollfd(fd: fileDescriptor, events:  Int16(Darwin.POLLIN), revents: 0)
        let pollResult = Darwin.poll(&pollfd, 1, 200)
        switch pollResult {
        case 0:
            // Timed-out
            return 0
        case 1:
            // Data ready for reading
            break
        default:
            // Error
            return -1
        }
        
        let result = Darwin.read(fileDescriptor, buffer, count)
        return result == -1 && (errno == EAGAIN || errno == EWOULDBLOCK) ? 0 : result
    }
    
    public func write(_ fileDescriptor: Int32, _ buffer: UnsafeRawPointer!, _ count: Int) -> Int {
        return Darwin.write(fileDescriptor, buffer, count)
    }
}
