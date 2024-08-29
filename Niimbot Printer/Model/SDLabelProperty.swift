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
    @Transient var orderedTextProperties: [SDTextProperty]? { get }
    var pngImage: Data { get set }
    var paperEANRawValue: String { get set }
    var date: Date { get set }
}

extension SDLabelProperty {
    @Transient var orderedTextProperties: [SDTextProperty]? {
        textProperties?.sorted(by: { first, second in
            first.orderId < second.orderId
        })
    }
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
        var orderId = 0
        self.textProperties = textProperties.map { item in
            let property = SDTextProperty(from: item, orderId: orderId)
            orderId += 1
            return property
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }

    @MainActor
    required init(textProperties: [SendableTextProperty], pngImage: Data, paperEANRawValue: String, date: Date = Date()) {
        var orderId = 0
        self.textProperties = textProperties.map { item in
            let property = SDTextProperty(from: item.toTextProperty(), orderId: orderId)
            orderId += 1
            return property
        }
        self.pngImage = pngImage
        self.paperEANRawValue = paperEANRawValue
        self.date = date
    }
    
    @Relationship(deleteRule: .cascade) var textProperties: [SDTextProperty]? = []
    @Attribute var pngImage: Data = Data()
    @Attribute var paperEANRawValue: String = ""
    @Attribute var date: Date = Date()
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
        var orderId = 0

        // Workaround: Create a deep copy via a non SwiftData structure so we are not using already stored data.
        self.textProperties = from.orderedTextProperties?.map({ $0.toTextProperty()}).map({
            let property = SDTextProperty(from: $0, orderId: orderId)
            orderId += 1
            return property

        })
        self.pngImage = from.pngImage
        self.paperEANRawValue = from.paperEANRawValue
        self.date = from.date
    }
    
    @Relationship(deleteRule: .cascade) var textProperties: [SDTextProperty]? = []
    @Attribute var pngImage: Data = Data()
    @Attribute var paperEANRawValue: String = ""
    @Attribute var date: Date = Date()
}

