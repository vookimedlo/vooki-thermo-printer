//
//  Decoration.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 17.07.2024.
//

import Foundation


public enum Decoration: Int, Equatable, CaseIterable, Sendable, Codable {
    case custom
    case frame, frame3, frame4, frame5
    case doubleFrame, doubleFrame3, doubleFrame4, doubleFrame5

    var name: String {
        switch self {
        case .custom:
            "Custom image"
        case .frame:
            "Full frame"
        case .frame3:
            "Frame 1/3"
        case .frame4:
            "Frame 1/4"
        case .frame5:
            "Frame 1/5"
        case .doubleFrame:
            "Double full frame"
        case .doubleFrame3:
            "Double frame 1/3"
        case .doubleFrame4:
            "Double frame 1/4"
        case .doubleFrame5:
            "Double frame 1/5"
        }
    }
    
    var frameDivider: CGFloat {
        switch self {
        case .frame, .doubleFrame: 2
        case .frame3, .doubleFrame3: 3
        case .frame4, .doubleFrame4: 4
        case .frame5, .doubleFrame5: 5
        default:
            1
        }
    }
    
    var isDoubleFrame: Bool {
        switch self {
        case .doubleFrame, .doubleFrame3, .doubleFrame4, .doubleFrame5:
            true
        default:
            false
        }
    }
}
