//
//  Margin.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation

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
