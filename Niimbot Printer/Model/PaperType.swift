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
         ean6971501224599 = "6971501224599", // 30*15 white
         ean02282280 = "02282280", // 30*15 white - came with printer
         ean6971501224568 = "6971501224568", // 30*12 white
         ean6972842743565 = "6972842743565" // 30*12 white
    
    nonisolated
    var physicalSizeInMillimeters: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            return CGSize(width: 30, height: 15)
        case .ean6971501224568, .ean6972842743565:
            return CGSize(width: 30, height: 12)
        case .unknown:
            return CGSize(width: 30, height: 15)
        }
    }
    
    nonisolated
    var physicalSizeInPixels: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            return CGSize(width: 240, height: 120)
        case .ean6971501224568, .ean6972842743565:
            return CGSize(width: 240, height: 96)
        case .unknown:
            return CGSize(width: 240, height: 120)
        }
    }
    
    nonisolated
    var printableSizeInMillimeters: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            return CGSize(width: 30, height: 10)
        case .ean6971501224568, .ean6972842743565:
            return CGSize(width: 30, height: 12)
        case .unknown:
            return CGSize(width: 30, height: 10)
        }
    }
    
    nonisolated
    var printableSizeInPixels: CGSize {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            return CGSize(width: 240, height: 80)
        case .ean6971501224568, .ean6972842743565:
            return CGSize(width: 240, height: 96)
        case .unknown:
            return CGSize(width: 240, height: 80)
        }
    }
    
    nonisolated
    var labelType: UInt8 {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            fallthrough
        case .ean6971501224568, .ean6972842743565:
            fallthrough
        case .unknown:
            return 1
        }
    }
    
    nonisolated
    var margin: Margins {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            return Margins(leading: 12, trailing: 10, top: 2, bottom: 2)
        case .ean6971501224568, .ean6972842743565:
            return Margins(leading: 5, trailing: 5, top: 2, bottom: 1)
        case .unknown:
            return Margins(leading: 12, trailing: 10, top: 10, bottom: 10)
        }
    }
    
    nonisolated
    var cornerRadius: Double {
        switch self {
        case .ean02282280, .ean6972842743589, .ean6971501224599:
            return 30
        case .ean6971501224568, .ean6972842743565:
            return 20
        case .unknown:
            return 30
        }
    }
}
