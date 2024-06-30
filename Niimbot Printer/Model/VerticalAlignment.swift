//
//  VerticalTextAlignment.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.06.2024.
//

import Foundation

@Observable
class VerticalTextAlignment: ObservableObject, Notifier {
    typealias Alignment = AlignmentView.VerticalAlignment
    
    var alignment: Alignment = .center {
        willSet {
            guard alignment != newValue else { return }
            notify(name: Notification.Name.App.verticalTextAlignment,
                   userInfo: [String : Alignment](dictionaryLiteral: (Notification.Keys.value, newValue)))
        }
    }
}
