//
//  Margin.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation
import SwiftUI

enum HorizontalMargin: Sendable, Equatable {
    case leading(size: Int)
    case trailing(size: Int)
    case none
    
    var edge: Edge.Set? {
        switch (self) {
        case .leading(size: _):
                .leading
        case .trailing(size: _):
                .trailing
        case .none:
            nil
        }
    }
    
    var size: Int {
        switch (self) {
        case .leading(size: let size), .trailing(size: let size):
            size
        case .none:
            0
        }
    }
    
    var fsize: Double {
        Double(size)
    }
}

enum VerticalMargin: Sendable, Equatable {
    case top(size: Int)
    case bottom(size: Int)
    case none
    
    var edge: Edge.Set? {
        switch (self) {
        case .top(size: _):
                .top
        case .bottom(size: _):
                .bottom
        case .none:
            nil
        }
    }
    
    var size: Int {
        switch (self) {
        case .top(size: let size), .bottom(size: let size):
            size
        case .none:
            0
        }
    }
    
    var fsize: Double {
        Double(size)
    }
}

struct Margin: Sendable, Equatable {
    var leading: Int
    var trailing: Int
    var top: Int
    var bottom: Int
    
    static func + (left: Margin, right: Margin) -> Margin {
        return Margin(leading: left.leading + right.leading,
                      trailing: left.trailing + right.trailing,
                      top: left.top + right.top,
                      bottom: left.bottom + right.bottom)
    }
}
