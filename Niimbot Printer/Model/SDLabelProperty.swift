//
//  SDLabelProperty.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 20.08.2024.
//

import Foundation
import SwiftData

@Model
class SDLabelProperty {
    @MainActor
    init(textProperties: [SDTextProperty], pngImage: Data, paperEANRawValue: String, date: Date) {
        self.textProperties = textProperties
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    @MainActor
    init(textProperties: [TextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        self.textProperties = textProperties.map { item in
            SDTextProperty(from: item)
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }

    @MainActor
    init(textProperties: [SendableTextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        self.textProperties = textProperties.map { item in
            SDTextProperty(from: item.toTextProperty())
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    var textProperties: [SDTextProperty]
    var pngImage: Data
    var paperEANRawValue: String
    var date: Date
}
