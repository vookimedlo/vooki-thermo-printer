/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

class TestHelper {
    static let isRunningTests: Bool = {
        guard let injectBundle = ProcessInfo.processInfo.environment["XCTestBundlePath"] as NSString? else {
            return false
        }

        return "xctest" == injectBundle.pathExtension
    }()
}
