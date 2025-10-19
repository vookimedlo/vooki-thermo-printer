/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

@MainActor
public enum AlertType: Int, Sendable {
    case none, printError, communicationError
    
    var title: String {
        switch self {
        case .communicationError: "Error"
        case .printError: "Error"
        case .none: ""
        }
    }
    var message: String {
        switch self {
        case .communicationError: return "Cannot communicate with the printer."
        case .printError: return "Unable to complete the print operation."
        case .none: return ""
        }
    }
}
