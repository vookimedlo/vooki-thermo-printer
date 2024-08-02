//
//  ToolbarItemPlacementExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 02.08.2024.
//

import SwiftUI


extension ToolbarItemPlacement {
    @MainActor static let appBar = accessoryBar(id: UUID().uuidString)
}
