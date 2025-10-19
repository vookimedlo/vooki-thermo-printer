//
//  AppDetailsEnvironmentKey.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.10.2025.
//

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
