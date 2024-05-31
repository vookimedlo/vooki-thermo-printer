//
//  PosixFileSystem.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation

public class PosixFileSystemAccess : FileSystemAccess {
    public func open(_ path: UnsafePointer<CChar>, _ oflag: Int32) -> Int32 {
        return Darwin.open(path, oflag)
    }
    
    @discardableResult
    public func close(_ fileDescriptor: Int32) -> Int32 {
        return Darwin.close(fileDescriptor)
    }
    
    public func read(_ fileDescriptor: Int32, _ buffer: UnsafeMutableRawPointer!, _ count: Int) -> Int {
        return Darwin.read(fileDescriptor, buffer, count)
    }
    
    public func write(_ fileDescriptor: Int32, _ buffer: UnsafeRawPointer!, _ count: Int) -> Int {
        return Darwin.write(fileDescriptor, buffer, count)
    }
}
