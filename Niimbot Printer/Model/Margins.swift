//
//  Margin.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation
import SwiftUI

protocol Marginable : Equatable, Sendable {
    var size: Int { get }
    var fsize: Double { get }
    
    static var none: Self { get }
    var isNone: Bool { get }
    
    var edge: Edge.Set? {get}
}

protocol HorizontalMarginable : Marginable, Sendable {
    static func leading(size: Int) -> Self
    static func trailing(size: Int) -> Self
    var isLeading: Bool { get }
    var isTrailing: Bool { get }
}

protocol VerticalMarginable : Marginable, Sendable {
    static func top(size: Int) -> Self
    static func bottom(size: Int) -> Self
    var isTop: Bool { get }
    var isBottom: Bool { get }
}
extension Marginable {
    var fsize: Double {
        Double(size)
    }
    
    var isNone: Bool {
        self == .none
    }
}

enum Margin: Sendable, Equatable, HorizontalMarginable, VerticalMarginable {
    case leading(size: Int)
    case trailing(size: Int)
    case top(size: Int)
    case bottom(size: Int)
    case none
    
    var edge: Edge.Set? {
        switch (self) {
        case .leading(size: _):
                .leading
        case .trailing(size: _):
                .trailing
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
        case .leading(size: let size), .trailing(size: let size), .top(size: let size), .bottom(size: let size):
            size
        case .none:
            0
        }
    }
    
    var isLeading: Bool {
        switch (self) {
        case .leading(size: _):
            true
        default:
            false
        }
    }
    
    var isTrailing: Bool {
        switch (self) {
        case .trailing(size: _):
            true
        default:
            false
        }
    }
    
    var isTop: Bool {
        switch (self) {
        case .top(size: _):
            true
        default:
            false
        }
    }
    
    var isBottom: Bool {
        switch (self) {
        case .bottom(size: _):
            true
        default:
            false
        }
    }
}

struct Margins: Sendable, Equatable {
    private var _leading = Margin.leading(size: 0)
    private var _trailing = Margin.trailing(size: 0)
    private var _top = Margin.top(size: 0)
    private var _bottom = Margin.bottom(size: 0)
    
    init(leading: Int, trailing: Int, top: Int, bottom: Int) {
        self.leading = leading
        self.trailing = trailing
        self.top = top
        self.bottom = bottom
    }
    
    var leading: Int {
        get {
            _leading.size
        }
        set(value) {
            _leading = Margin.leading(size: value)
        }
    }
    
    var leadingMargin: any HorizontalMarginable {
        _leading
    }
    
    var trailing: Int {
        get {
            _trailing.size
        }
        set(value) {
            _trailing = Margin.trailing(size: value)
        }
    }
    
    var trailingMargin: any HorizontalMarginable {
        _trailing
    }
    
    var top: Int {
        get {
            _top.size
        }
        set(value) {
            _top = Margin.top(size: value)
        }
    }
    
    var topMargin: any VerticalMarginable {
        _top
    }
    
    var bottom: Int {
        get {
            _bottom.size
        }
        set(value) {
            _bottom = Margin.bottom(size: value)
        }
    }
    
    var bottomMargin: any VerticalMarginable {
        _bottom
    }

    static func + (left: Margins, right: Margins) -> Margins {
        return Margins(leading: left.leading + right.leading,
                       trailing: left.trailing + right.trailing,
                       top: left.top + right.top,
                       bottom: left.bottom + right.bottom)
    }
}
