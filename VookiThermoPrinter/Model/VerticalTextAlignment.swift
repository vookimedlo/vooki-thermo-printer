//
//  VerticalTextAlignment.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.06.2024.
//

import Foundation

@MainActor
@Observable
final class VerticalTextAlignment: ObservableObject, Notifiable {
    typealias Alignment = AlignmentView.VerticalAlignment
    
    var alignment: Alignment = .center {
        willSet {
            guard alignment != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
}
