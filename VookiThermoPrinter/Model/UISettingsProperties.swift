//
//  UISettingsProperties.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 06.08.2024.
//

import Foundation

@MainActor
@Observable
final class UISettingsProperties: ObservableObject {
    var showHorizontalMarginGuideline: Bool = true
    var showVerticalMarginGuideline: Bool = true
}

