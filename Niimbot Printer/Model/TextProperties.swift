//
//  TextProperties.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.07.2024.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class TextProperty: ObservableObject, Notifiable {
    public enum WhatToPrint: Int, CaseIterable, SegmentedPrickerHelp, Sendable, Codable {
        case text, qr, image
        
        var help: String {
            switch self {
            case .text: return "Text"
            case .qr: return "QR code"
            case .image: return "Image"
            }
        }
    }
    
    var horizontalAlignment: HorizontalTextAlignment = HorizontalTextAlignment()
    var verticalAlignment: VerticalTextAlignment = VerticalTextAlignment()
    var fontDetails: FontDetails = FontDetails()
    var text: String = "" {
        willSet {
            guard text != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
    var whatToPrint: WhatToPrint = .text
    {
        willSet {
            guard whatToPrint != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
    var squareCodeSize = 80
    {
        willSet {
            guard squareCodeSize != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
    var image: Data = Data()
    {
        willSet {
            guard image != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
    
    var imageDecoration: Decoration = .custom
    {
        willSet {
            guard imageDecoration != newValue else { return }
            image = Data()
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
    
    var margin = Margins(leading: 0, trailing: 0, top: 0, bottom: 0)
    {
        willSet {
            guard margin != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
}

@MainActor
@Observable
class TextProperties: ObservableObject {
    var properties: Array<TextProperty> = [TextProperty()]
}

struct SendableTextProperty: Sendable, Codable {
    @MainActor
    init(from: TextProperty) {
        self.whatToPrint = from.whatToPrint
        self.horizontalAlignment = from.horizontalAlignment.alignment
        self.verticalAlignment = from.verticalAlignment.alignment
        self.squareCodeSize = from.squareCodeSize
        self.image = from.image
        self.imageDecoration = from.imageDecoration
        self.text = from.text
        self.fontFamily = from.fontDetails.family
        self.fontName = from.fontDetails.name
        self.fontSize = from.fontDetails.size
        self.margin = from.margin
    }
    
    @MainActor
    func toTextProperty() -> TextProperty {
        let property = TextProperty()
        property.whatToPrint = self.whatToPrint
        property.horizontalAlignment.alignment = self.horizontalAlignment
        property.verticalAlignment.alignment = self.verticalAlignment
        property.squareCodeSize = self.squareCodeSize
        property.image = self.image
        property.imageDecoration = self.imageDecoration
        property.text = self.text
        property.fontDetails.family = self.fontFamily
        property.fontDetails.name = self.fontName
        property.fontDetails.size = self.fontSize
        property.margin = self.margin
        
        return property
    }
    
    let whatToPrint: TextProperty.WhatToPrint
    let horizontalAlignment: HorizontalTextAlignment.Alignment
    let verticalAlignment: VerticalTextAlignment.Alignment
    let squareCodeSize: Int
    let image: Data
    let imageDecoration: Decoration
    let text: String
    let fontFamily: String
    let fontName: String
    let fontSize: Int
    let margin: Margins
}

@Model
final class SDTextProperty {
    @MainActor
    init(whatToPrint: TextProperty.WhatToPrint, horizontalAlignment: HorizontalTextAlignment.Alignment, verticalAlignment: VerticalTextAlignment.Alignment, squareCodeSize: Int, image: Data, imageDecoration: Decoration, text: String, fontFamily: String, fontName: String, fontSize: Int, margin: Margins, orderId: Int = 0) {
        self.whatToPrint = whatToPrint
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.squareCodeSize = squareCodeSize
        self.image = image
        self.imageDecoration = imageDecoration
        self.text = text
        self.fontFamily = fontFamily
        self.fontName = fontName
        self.fontSize = fontSize
        self.margin = margin
        self.orderId = orderId
    }
    
    @MainActor
    init(from: TextProperty, orderId: Int = 0) {
        self.whatToPrint = from.whatToPrint
        self.horizontalAlignment = from.horizontalAlignment.alignment
        self.verticalAlignment = from.verticalAlignment.alignment
        self.squareCodeSize = from.squareCodeSize
        self.image = from.image
        self.imageDecoration = from.imageDecoration
        self.text = from.text
        self.fontFamily = from.fontDetails.family
        self.fontName = from.fontDetails.name
        self.fontSize = from.fontDetails.size
        self.margin = from.margin
        self.orderId = orderId
    }
    
    @MainActor
    func toTextProperty() -> TextProperty {
        let property = TextProperty()
        property.whatToPrint = self.whatToPrint
        property.horizontalAlignment.alignment = self.horizontalAlignment
        property.verticalAlignment.alignment = self.verticalAlignment
        property.squareCodeSize = self.squareCodeSize
        property.image = self.image
        property.imageDecoration = self.imageDecoration
        property.text = self.text
        property.fontDetails.family = self.fontFamily
        property.fontDetails.name = self.fontName
        property.fontDetails.size = self.fontSize
        property.margin = self.margin
        
        return property
    }
    
    @Relationship(inverse:\SDHistoryLabelProperty.textProperties) var HistoryLabelTextProperties: [SDHistoryLabelProperty]?
    @Relationship(inverse:\SDSavedLabelProperty.textProperties) var SavedLabelTextProperties: [SDSavedLabelProperty]?

    @Attribute var orderId: Int = 0
    @Attribute var whatToPrint: TextProperty.WhatToPrint = TextProperty.WhatToPrint.text
    @Attribute var horizontalAlignment: HorizontalTextAlignment.Alignment =  HorizontalTextAlignment.Alignment.center
    @Attribute var verticalAlignment: VerticalTextAlignment.Alignment = VerticalTextAlignment.Alignment.center
    @Attribute var squareCodeSize: Int = 0
    @Attribute var image: Data = Data()
    @Attribute var imageDecoration: Decoration = Decoration.custom
    @Attribute var text: String = ""
    @Attribute var fontFamily: String = ""
    @Attribute var fontName: String = ""
    @Attribute var fontSize: Int = 0
    @Attribute var margin: Margins = Margins(leading: 0, trailing: 0, top: 0, bottom: 0)
}
