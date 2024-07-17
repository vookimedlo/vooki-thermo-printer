//
//  HorizontalTextAlignment.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.06.2024.
//

import Foundation

@MainActor
@Observable
final class HorizontalTextAlignment: ObservableObject, Notifier {
    typealias Alignment = AlignmentView.HorizontalAlignment
    
    var alignment: Alignment = .center {
        willSet {
            guard alignment != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
}
