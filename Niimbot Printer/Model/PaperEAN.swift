//
//  PaperEAN.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation


enum PaperEAN: String, Sendable, CaseIterable {
    case unknown = "0",
         ean6972842743589 = "6972842743589", // 30*15 white
         ean6971501224599 = "6971501224599", // 30*15 white
         ean02282280 = "02282280", // 30*15 white - came with printer
         ean6971501224568 = "6971501224568", // 30*12 white
         ean6972842743565 = "6972842743565" // 30*12 white
    
    private enum PaperDefinition: String, Sendable, CaseIterable {
        case unknown,
             paper30x15White,
             paper30x12White
    }
    
    struct Paper: Sendable, Equatable {
        let physicalSizeInMillimeters: CGSize
        let physicalSizeInPixels: CGSize
        let printableSizeInMillimeters: CGSize
        let printableSizeInPixels: CGSize
        let labelType: UInt8
        let margin: Margins
        let cornerRadius: Double
    }
    
    static private let lutTypeToDefinition: [Self: PaperDefinition] = [.unknown: .unknown,
                                                               .ean6972842743589: .paper30x15White,
                                                               .ean6971501224599: .paper30x15White,
                                                               .ean02282280: .paper30x15White,
                                                               .ean6971501224568: .paper30x12White,
                                                               .ean6972842743565: .paper30x12White,
    ]
    
    static private let lutDefinitionToPaper: [PaperDefinition: Paper] = [.unknown:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 30, height: 15),
                                                          physicalSizeInPixels: CGSize(width: 240, height: 120),
                                                          printableSizeInMillimeters: CGSize(width: 30, height: 10),
                                                          printableSizeInPixels: CGSize(width: 240, height: 80),
                                                          labelType: 1,
                                                          margin: Margins(leading: 12, trailing: 10, top: 10, bottom: 10),
                                                          cornerRadius: 30),
                                                .paper30x15White:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 30, height: 15),
                                                          physicalSizeInPixels: CGSize(width: 240, height: 120),
                                                          printableSizeInMillimeters: CGSize(width: 30, height: 10),
                                                          printableSizeInPixels: CGSize(width: 240, height: 80),
                                                          labelType: 1,
                                                          margin: Margins(leading: 12, trailing: 10, top: 2, bottom: 2),
                                                          cornerRadius: 30),
                                                .paper30x12White:
                                                    Paper(physicalSizeInMillimeters: CGSize(width: 30, height: 12),
                                                          physicalSizeInPixels: CGSize(width: 240, height: 96),
                                                          printableSizeInMillimeters: CGSize(width: 30, height: 12),
                                                          printableSizeInPixels: CGSize(width: 240, height: 96),
                                                          labelType: 1,
                                                          margin: Margins(leading: 5, trailing: 5, top: 2, bottom: 1),
                                                          cornerRadius: 20),
    ]
    
    nonisolated
    var physicalSizeInMillimeters: CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.physicalSizeInMillimeters
    }
    
    nonisolated
    var physicalSizeInPixels: CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.physicalSizeInPixels
    }
    
    nonisolated
    var printableSizeInMillimeters: CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.printableSizeInMillimeters
    }
    
    nonisolated
    var printableSizeInPixels: CGSize {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.printableSizeInPixels
    }
    
    nonisolated
    var labelType: UInt8 {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.labelType
    }
    
    nonisolated
    var margin: Margins {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.margin
    }
    
    nonisolated
    var cornerRadius: Double {
        Self.lutDefinitionToPaper[Self.lutTypeToDefinition[self]!]!.cornerRadius
    }
    
    nonisolated
    static func testIntegrity() -> Bool {
        guard Self.allCases.count == lutTypeToDefinition.count else { return false }
        guard Self.allCases.sorted(by: { $0.rawValue < $1.rawValue }).elementsEqual(lutTypeToDefinition.keys.sorted(by: { $0.rawValue < $1.rawValue })) else { return false }
        guard NSSet(array: PaperDefinition.allCases).isEqual(to: NSSet(array: lutTypeToDefinition.values.reversed())) else { return false }

        guard PaperDefinition.allCases.count == lutDefinitionToPaper.count else { return false }
        guard PaperDefinition.allCases.sorted(by: { $0.rawValue < $1.rawValue }).elementsEqual(lutDefinitionToPaper.keys.sorted(by: { $0.rawValue < $1.rawValue })) else { return false }

        return true
    }
}
