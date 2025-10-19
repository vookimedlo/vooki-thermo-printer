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
final class HorizontalTextAlignment: ObservableObject, Notifiable {
    typealias Alignment = AlignmentView.HorizontalAlignment
    
    var alignment: Alignment = .center {
        willSet {
            guard alignment != newValue else { return }
            notify(name: Notification.Name.App.textPropertiesUpdated)
        }
    }
}
