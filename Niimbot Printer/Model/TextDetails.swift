//
//  TextDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation

@Observable
class TextDetails: ObservableObject, Notifier {
    var text: String = "" {
        willSet {
            guard text != newValue else { return }
            notify(name: Notification.Name.App.textToPrint,
                   userInfo: [String : String](dictionaryLiteral: (Notification.Keys.value, newValue)))
        }
    }
}
