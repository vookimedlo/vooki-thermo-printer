/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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
