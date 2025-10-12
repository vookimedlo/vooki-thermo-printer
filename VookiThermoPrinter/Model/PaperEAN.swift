//
//  PaperEAN.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation
import SwiftUI


enum PaperEAN: String, Sendable, CaseIterable {
    case unknown = "0",
         ean6972842743589 = "6972842743589", // 30*15 white
         ean6971501224599 = "6971501224599", // 30*15 white
         ean02282280 = "02282280",           // 30*15 white - came with printer
         ean6971501224568 = "6971501224568", // 30*12 white
         ean6972842743565 = "6972842743565", // 30*12 white
         ean6971501224582 = "6971501224582", // 26*15 white
         ean6971501224605 = "6971501224605", // 50*15 white
         ean6971501224551 = "6971501224551", // 22*12 white
         ean6972842743558 = "6972842743558", // 22*12 white
         ean10252110 = "10252110",           // 75*12 white
         ean6972842743787 = "6972842743787", // 109*12.5 white cable - 12.5*74+7*35
         ean6972842743824 = "6972842743824", // 109*12.5 yellow cable - 12.5*74+7*35
         ean6972842743817 = "6972842743817", // 109*12.5 red cable - 12.5*74+7*35
         ean6972842743800 = "6972842743800", // 109*12.5 green cable - 12.5*74+7*35
         ean6972842743794 = "6972842743794", // 109*12.5 blue cable - 12.5*74+7*35
         ean6971501229778 = "6971501229778"  // 30*12 white
    
    enum DPI: CGFloat, Sendable, CaseIterable {
        case dpi203 = 203,
             dpi300 = 300
    }

    private enum PaperDefinition: String, Sendable, CaseIterable {
        case unknown,
             paper30x15,
             paper30x12,
             paper26x15,
             paper50x15,
             paper22x12,
             paper75x12,
             paper109x12_5
    }
    
    struct Paper: Sendable, Equatable {
        let physicalSizeInMillimeters: CGSize
        let printableSizeInMillimeters: CGSize
        let labelType: UInt8
        let margin: Margins
        let cornerRadius: Double
        
        func physicalSizeInPixels(dpi: DPI) -> CGSize {
            let widthPixels = (physicalSizeInMillimeters.width / 25.4) * dpi.rawValue
            let heightPixels = (physicalSizeInMillimeters.height / 25.4) * dpi.rawValue
            return CGSize(width: widthPixels.rounded(), height: heightPixels.rounded())
        }
        
        func printableSizeInPixels(dpi: DPI) -> CGSize {
            let widthPixels = (printableSizeInMillimeters.width / 25.4) * dpi.rawValue
            let heightPixels = (printableSizeInMillimeters.height / 25.4) * dpi.rawValue
            return CGSize(width: widthPixels.rounded(), height: heightPixels.rounded())
        }
    }
    
    enum ColorAttribute: Sendable, Equatable {
        case white, yellow, blue, green, red, various
        
        var color: (String, Color) {
            switch (self) {
            case .white:
                ("white", Color.white)
            case .yellow:
                ("yellow", Color.yellow)
            case .blue:
                ("blue", Color.blue)
            case .green:
                ("green", Color.green)
            case .red:
                ("red", Color.red)
            case .various:
                ("various", Color.clear)
            }
        }
    }
    
    struct Attribute: Sendable, Equatable {
        let color: ColorAttribute
        let isCable: Bool
        
        init(color: ColorAttribute = ColorAttribute.white, isCable: Bool = false) {
            self.color = color
            self.isCable = isCable
        }
    }
    
    static private let lutTypeToDefinition: [Self: (PaperDefinition, Attribute)] = [.unknown: (.unknown, Attribute()),
                                                                       .ean6972842743589: (.paper30x15, Attribute()),
                                                                       .ean6971501224599: (.paper30x15, Attribute()),
                                                                       .ean02282280:      (.paper30x15, Attribute()),
                                                                       .ean6971501224568: (.paper30x12, Attribute()),
                                                                       .ean6972842743565: (.paper30x12, Attribute()),
                                                                       .ean6971501224582: (.paper26x15, Attribute()),
                                                                       .ean6971501224605: (.paper50x15, Attribute()),
                                                                       .ean6971501224551: (.paper22x12, Attribute()),
                                                                       .ean6972842743558: (.paper22x12, Attribute()),
                                                                       .ean10252110:      (.paper75x12, Attribute()),
                                                                       .ean6972842743787: (.paper109x12_5, Attribute(isCable: true)),
                                                                       .ean6972842743824: (.paper109x12_5, Attribute(color: .yellow,
                                                                                                                     isCable: true)),
                                                                       .ean6972842743817: (.paper109x12_5, Attribute(color: .red,
                                                                                                                     isCable: true)),
                                                                       .ean6972842743800: (.paper109x12_5, Attribute(color: .green,
                                                                                                                     isCable: true)),
                                                                       .ean6972842743794: (.paper109x12_5, Attribute(color: .blue,
                                                                                                                     isCable: true)),
                                                                       .ean6971501229778: (.paper30x12, Attribute(color: .various)),
    ]
    
    static private let lutDefinitionToPaper: [PaperDefinition: Paper] = [.unknown:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 30, height: 15),
                                                          printableSizeInMillimeters: CGSize(width: 30, height: 10),
                                                          labelType: 1,
                                                          margin: Margins(leading: 12, trailing: 10, top: 10, bottom: 10),
                                                          cornerRadius: 30),
                                                .paper30x15:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 30, height: 15),
                                                          printableSizeInMillimeters: CGSize(width: 30, height: 10),
                                                          labelType: 1,
                                                          margin: Margins(leading: 12, trailing: 10, top: 2, bottom: 2),
                                                          cornerRadius: 30),
                                                .paper30x12:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 30, height: 12),
                                                          printableSizeInMillimeters: CGSize(width: 30, height: 12),
                                                          labelType: 1,
                                                          margin: Margins(leading: 5, trailing: 5, top: 2, bottom: 1),
                                                          cornerRadius: 20),
                                                .paper26x15:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 26, height: 15),
                                                          printableSizeInMillimeters: CGSize(width: 26, height: 10),
                                                          labelType: 1,
                                                          margin: Margins(leading: 12, trailing: 10, top: 2, bottom: 2),
                                                          cornerRadius: 30),
                                                .paper50x15:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 50, height: 15),
                                                          printableSizeInMillimeters: CGSize(width: 50, height: 10),
                                                          labelType: 1,
                                                          margin: Margins(leading: 12, trailing: 10, top: 2, bottom: 2),
                                                          cornerRadius: 30),
                                                .paper22x12:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 22, height: 12),
                                                          printableSizeInMillimeters: CGSize(width: 22, height: 12),
                                                          labelType: 1,
                                                          margin: Margins(leading: 5, trailing: 5, top: 2, bottom: 1),
                                                          cornerRadius: 20),
                                                .paper75x12:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 75, height: 12),
                                                          printableSizeInMillimeters: CGSize(width: 75, height: 12),
                                                          labelType: 1,
                                                          margin: Margins(leading: 5, trailing: 5, top: 2, bottom: 1),
                                                          cornerRadius: 20),
                                                .paper109x12_5:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 109, height: 12.5),
                                                          printableSizeInMillimeters: CGSize(width: 74, height: 12),
                                                          labelType: 1,
                                                          margin: Margins(leading: 5, trailing: 5, top: 2, bottom: 1),
                                                          cornerRadius: 20),
    ]
    
    nonisolated
    var physicalSizeInMillimeters: CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.physicalSizeInMillimeters
    }
    
    nonisolated
    func physicalSizeInPixels(dpi: DPI) -> CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.physicalSizeInPixels(dpi: dpi)
    }
    
    nonisolated
    var printableSizeInMillimeters: CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.printableSizeInMillimeters
    }
    
    nonisolated
    func printableSizeInPixels(dpi: DPI) -> CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.printableSizeInPixels(dpi: dpi)
    }
    
    nonisolated
    var labelType: UInt8 {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.labelType
    }
    
    nonisolated
    var margin: Margins {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.margin
    }
    
    nonisolated
    var cornerRadius: Double {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!.0]!.cornerRadius
    }
    
    nonisolated
    var colorName: String {
        Self.lutTypeToDefinition[self]!.1.color.color.0
    }
    
    nonisolated
    var color: Color {
        Self.lutTypeToDefinition[self]!.1.color.color.1
    }
    
    nonisolated
    var isCable: Bool {
        Self.lutTypeToDefinition[self]!.1.isCable
    }
    
    nonisolated
    var description: String {
        isCable ? "Cable: \(physicalSizeInMillimeters.width)mm * \(physicalSizeInMillimeters.height)mm" : "Plain: \(physicalSizeInMillimeters.width)mm * \(physicalSizeInMillimeters.height)mm"
    }
    
    nonisolated
    static func testIntegrity() -> Bool {
        guard Self.allCases.count == lutTypeToDefinition.count else { return false }
        guard Self.allCases.sorted(by: { $0.rawValue < $1.rawValue }).elementsEqual(lutTypeToDefinition.keys.sorted(by: { $0.rawValue < $1.rawValue })) else { return false }
        guard NSSet(array: PaperDefinition.allCases).isEqual(to: NSSet(array: lutTypeToDefinition.values.compactMap({ (definition, _) -> PaperDefinition? in definition }))) else { return false }

        guard PaperDefinition.allCases.count == lutDefinitionToPaper.count else { return false }
        guard PaperDefinition.allCases.sorted(by: { $0.rawValue < $1.rawValue }).elementsEqual(lutDefinitionToPaper.keys.sorted(by: { $0.rawValue < $1.rawValue })) else { return false }

        return true
    }
}

