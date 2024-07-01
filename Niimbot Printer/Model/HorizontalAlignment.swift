//
//  HorizontalAlignment.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.06.2024.
//

import Foundation

@Observable
class HorizontalTextAlignment: ObservableObject, Notifier {
    typealias Alignment = AlignmentView.HorizontalAlignment
    
    var alignment: Alignment = .center {
        willSet {
            guard alignment != newValue else { return }
            notify(name: Notification.Name.App.horizontalTextAlignment,
                   userInfo: [String : Alignment](dictionaryLiteral: (Notification.Keys.value, newValue)))
        }
    }
}
