//
//  ArrayExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 29.05.2024.
//

import Foundation

extension Array {
    init(pointer: UnsafePointer<Element>, count: Int) {
        self = Array(UnsafeBufferPointer<Element>(start: pointer, count: count))
    }
    
    init(rawPointer: UnsafeRawPointer, count: Int) {
        self = Array(UnsafeBufferPointer<Element>(start: rawPointer.bindMemory(to: Element.self,
                                                                               capacity: count),
                                                  count: count))
    }
}

extension Array {
    func findFirstMatching(predicate: (Element) -> Bool) -> Element? {
        for item in self {
            if predicate(item) {
                return item
            }
        }
        return nil
    }
}

extension Array<UInt8> {
    func toUInt16(fromBigEndian: Bool = true) -> UInt16? {
        guard self.count == 2 else {
            return nil
        }
        return fromBigEndian ? ((UInt16(self[0]) << 8) + UInt16(self[1])) : ((UInt16(self[1]) << 8) + UInt16(self[0]))
    }
}

extension Array<UInt8> {
    func hexEncodedString(options: Data.HexEncodingOptions = []) -> String {
        let format = { (options: Data.HexEncodingOptions) -> String in
            let caseSensitiveFormat = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
            return (options.contains(.prefix) ? "0x" : "") + caseSensitiveFormat
        }(options)
        
        let separator = { (options: Data.HexEncodingOptions) -> String in
            if options.contains(.commaSeparator) && options.contains(.spaceSeparator) { return "" }
            if options.contains(.commaSeparator) { return ", " }
            if options.contains(.spaceSeparator) { return " " }
            return ""
        }(options)
        
        return self.map { String(format: format, $0) }.joined(separator: separator)
    }
}

extension ArraySlice<UInt8> {
    func decEncodedString() -> String {
        return self.map { String(format: "%u", $0) }.joined(separator: "")
    }
}

