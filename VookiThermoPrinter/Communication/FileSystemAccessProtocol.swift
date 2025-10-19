//
//  FileSystemProtocol.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation

public protocol FileSystemAccess {
    func open(_ path: UnsafePointer<CChar>, _ oflag: Int32) -> Int32
    
    @discardableResult
    func close(_ fileDescriptor: Int32) -> Int32
    func read(_ fileDescriptor: Int32, _ buffer: UnsafeMutableRawPointer!, _ count: Int) -> Int
    func write(_ fileDescriptor: Int32, _ buffer: UnsafeRawPointer!, _ count: Int) -> Int
}
