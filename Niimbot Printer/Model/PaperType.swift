//
//  PaperType.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation

public enum PaperType: String, Sendable {
    case unknown = "0",
         ean6972842743589 = "6972842743589", // 30*15 white
         ean02282280 = "02282280" // 30*15 white - came with printer
    
    nonisolated
    var physicalSizeInMillimeters: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589:
            return CGSize(width: 30, height: 15)
        case .unknown:
            return CGSize(width: 30, height: 15)
        }
    }
    
    nonisolated
    var physicalSizeInPixels: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589:
            return CGSize(width: 240, height: 120)
        case .unknown:
            return CGSize(width: 240, height: 120)
        }
    }
    
    nonisolated
    var printableSizeInMillimeters: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589:
            return CGSize(width: 30, height: 10)
        case .unknown:
            return CGSize(width: 30, height: 10)
        }
    }
    
    nonisolated
    var printableSizeInPixels: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589:
            return CGSize(width: 240, height: 80)
        case .unknown:
            return CGSize(width: 240, height: 80)
        }
    }
    
    nonisolated
    var labelType: UInt8 {
        switch self {
        case .ean02282280, .ean6972842743589:
            fallthrough
        case .unknown:
            return 1
        }
    }
    
    nonisolated
    var margin: Margin {
        switch self {
        case .ean02282280, .ean6972842743589:
            return Margin(left: 12, right: 10, up: 2, bottom: 2)
        case .unknown:
            return Margin(left: 12, right: 10, up: 10, bottom: 10)
        }
    }
}
