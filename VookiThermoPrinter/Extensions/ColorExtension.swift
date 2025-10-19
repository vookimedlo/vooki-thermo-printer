//
//  ColorExtension.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 05.10.2024.
//

import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 0xFF,
            green: Double((hex >> 08) & 0xFF) / 0xFF,
            blue: Double((hex >> 00) & 0xFF) / 0xFF,
            opacity: alpha
        )
    }

    static var lila: Color {
        .init(hex: 0x9370DB)
    }
}
