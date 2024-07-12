//
//  TextProperties.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.07.2024.
//

import Foundation

@Observable
class TextProperty: ObservableObject, Notifier {
    public enum WhatToPrint: Int, CaseIterable, SegmentedPrickerHelp {
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

@Observable
class TextProperties: ObservableObject {
    var properties: Array<TextProperty> = [TextProperty()]
}
