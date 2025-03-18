//
//  FixedWidthInteger.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 10.06.2024.
//

import Foundation

extension FixedWidthInteger {
    public var bytes: [UInt8] {
        var source = self
        return Array<UInt8>(rawPointer: &source, count: MemoryLayout<Self>.size)
    }
}
