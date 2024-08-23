//
//  SavedLabelProperty.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 20.08.2024.
//

import Foundation

@MainActor
struct SavedLabelProperty: Identifiable, Sendable {
    let id: String = UUID().uuidString
    
    init(textProperties: [SendableTextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date.now) {
        self.textProperties = textProperties
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }

    let textProperties: [SendableTextProperty]
    let pngImage: Data
    let paperEANRawValue: String
    let date: Date
}

@MainActor
@Observable
class SavedLabelProperties: ObservableObject {
    var properties: [SavedLabelProperty] = []
}
