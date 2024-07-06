//
//  TextProperties.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.07.2024.
//

import Foundation

@Observable
class TextProperty: ObservableObject, Notifier {
    var horizontalAlignment: HorizontalTextAlignment = HorizontalTextAlignment()
    var verticalAlignment: VerticalTextAlignment = VerticalTextAlignment()
    var fontDetails: FontDetails = FontDetails()
    var text: String = "" {
        willSet {
            guard text != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
}

@Observable
class TextProperties: ObservableObject {
    var properties: Array<TextProperty> = [TextProperty()]
}
