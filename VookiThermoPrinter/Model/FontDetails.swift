//
//  FontDetails.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation

@MainActor
@Observable
final class FontDetails: ObservableObject, Notifiable {
    var family: String = "Chalkboard"
    
    var name: String = "Chalkboard" {
        willSet {
            guard name != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
    
    var size: Int = 20 {
        willSet {
            guard size != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
}
