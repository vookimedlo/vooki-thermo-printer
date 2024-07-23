//
//  TextProperties.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.07.2024.
//

import Foundation

@MainActor
@Observable
final class TextProperty: ObservableObject, Notifiable {
    public enum WhatToPrint: Int, CaseIterable, SegmentedPrickerHelp, Sendable {
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
}

@MainActor
@Observable
class TextProperties: ObservableObject {
    var properties: Array<TextProperty> = [TextProperty()]
}

struct SendableTextProperty: Sendable {
    @MainActor
    init(from: TextProperty) {
        self.whatToPrint = from.whatToPrint
        self.horizontalAlignment = from.horizontalAlignment.alignment
        self.verticalAlignment = from.verticalAlignment.alignment
        self.squareCodeSize = from.squareCodeSize
        self.image = from.image
        self.imageDecoration = from.imageDecoration
        self.text = from.text
        self.fontName = from.fontDetails.name
        self.fontSize = from.fontDetails.size
    }
    
    let whatToPrint: TextProperty.WhatToPrint
    let horizontalAlignment: HorizontalTextAlignment.Alignment
    let verticalAlignment: VerticalTextAlignment.Alignment
    let squareCodeSize: Int
    let image: Data
    let imageDecoration: Decoration
    let text: String
    let fontName: String
    let fontSize: Int
}
