//
//  IOProtocol.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation

public protocol IO {
    func open() throws
    func close()
    func readBytes(into buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int
    func writeBytes(from buffer: UnsafeRawPointer, size: Int) throws -> Int
    var name: String { get }
}
