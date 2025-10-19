/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2025 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import SwiftUI

// This EnvironmentKey stores an AppDetails value in the environment.
private struct AppDetailsEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppDetails = DefaultAppDetails.defaultValue
}

extension EnvironmentValues {
    // Expose the full AppDetails via the environment
    var appDetails: AppDetails {
        get { self[AppDetailsEnvironmentKey.self] }
        set { self[AppDetailsEnvironmentKey.self] = newValue }
    }
}

