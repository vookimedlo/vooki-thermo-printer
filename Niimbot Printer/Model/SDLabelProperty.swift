//
//  SDLabelProperty.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 20.08.2024.
//

import Foundation
import SwiftData

protocol SDLabelProperty: PersistentModel {
    @MainActor
    init(textProperties: [SDTextProperty], pngImage: Data, paperEANRawValue: String, date: Date)
    
    @MainActor
    init(textProperties: [TextProperty], pngImage: Data, paperEANRawValue: String, date: Date)

    @MainActor
    init(textProperties: [SendableTextProperty], pngImage: Data, paperEANRawValue: String, date: Date)

    var textProperties: [SDTextProperty]? { get set }
    var pngImage: Data { get set }
    var paperEANRawValue: String { get set }
    var date: Date { get set }
}

@Model
final class SDHistoryLabelProperty: SDLabelProperty {
    @MainActor
    required init(textProperties: [SDTextProperty], pngImage: Data, paperEANRawValue: String, date: Date) {
        self.textProperties = textProperties
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    @MainActor
    required init(textProperties: [TextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        self.textProperties = textProperties.map { item in
            SDTextProperty(from: item)
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }

    @MainActor
    required init(textProperties: [SendableTextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        self.textProperties = textProperties.map { item in
            SDTextProperty(from: item.toTextProperty())
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    var textProperties: [SDTextProperty]? = []
    var pngImage: Data = Data()
    var paperEANRawValue: String = ""
    var date: Date = Date()
}

@Model
final class SDSavedLabelProperty: SDLabelProperty {
    @MainActor
    required init(textProperties: [SDTextProperty], pngImage: Data, paperEANRawValue: String, date: Date) {
        self.textProperties = textProperties
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    @MainActor
    required init(textProperties: [TextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        self.textProperties = textProperties.map { item in
            SDTextProperty(from: item)
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }

    @MainActor
    required init(textProperties: [SendableTextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        self.textProperties = textProperties.map { item in
            SDTextProperty(from: item.toTextProperty())
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    @MainActor
    init(from: any SDLabelProperty) {
        // Workaround: Create a deep copy via a non SwiftData structure so we are not using already stored data.
        self.textProperties = from.textProperties?.map({ $0.toTextProperty()}).map({ SDTextProperty(from: $0)})
        self.pngImage = from.pngImage
        self.paperEANRawValue = from.paperEANRawValue
        self.date = from.date
    }
    
    var textProperties: [SDTextProperty]? = []
    var pngImage: Data = Data()
    var paperEANRawValue: String = ""
    var date: Date = Date()
}

