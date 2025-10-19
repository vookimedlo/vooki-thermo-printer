//
//  TestHelper.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 01.08.2024.
//

import Foundation

class TestHelper {
    static let isRunningTests: Bool = {
        guard let injectBundle = ProcessInfo.processInfo.environment["XCTestBundlePath"] as NSString? else {
            return false
        }

        return "xctest" == injectBundle.pathExtension
    }()
}
