//
//  DpiEnvironmentKey.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.10.2025.
//


import SwiftUI

private struct DpiEnvironmentKey: EnvironmentKey {
    static let defaultValue: PaperEAN.DPI = .dpi203
}

extension EnvironmentValues {
    var dpi: PaperEAN.DPI {
        get { self[DpiEnvironmentKey.self] }
        set { self[DpiEnvironmentKey.self] = newValue }
    }
}
