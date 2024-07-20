//
//  DataExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

extension Data {
    public struct HexEncodingOptions: OptionSet, Sendable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        public static let prefix = HexEncodingOptions(rawValue: 1 << 1)
        public static let commaSeparator = HexEncodingOptions(rawValue: 1 << 2)
        public static let spaceSeparator = HexEncodingOptions(rawValue: 1 << 3)
    }

    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = { (options: HexEncodingOptions) -> String in
            let caseSensitiveFormat = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
            return (options.contains(.prefix) ? "0x" : "") + caseSensitiveFormat
        }(options)
        
        let separator = { (options: HexEncodingOptions) -> String in
            if options.contains(.commaSeparator) && options.contains(.spaceSeparator) { return "" }
            if options.contains(.commaSeparator) { return ", " }
            if options.contains(.spaceSeparator) { return " " }
            return ""
        }(options)
        
        return self.map { String(format: format, $0) }.joined(separator: separator)
    }
}

extension Data {
    func toUInt16(fromBigEndian: Bool = true) -> UInt16? {
        guard self.count == 2 else {
            return nil
        }
        return fromBigEndian ? ((UInt16(self[startIndex]) << 8) + UInt16(self[startIndex + 1])) : ((UInt16(self[startIndex + 1]) << 8) + UInt16(self[startIndex]))
    }
}
