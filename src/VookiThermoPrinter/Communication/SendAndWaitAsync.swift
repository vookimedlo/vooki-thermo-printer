/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation
import os

public class SendAndWaitAsync {
    public enum WaitError: Error {
        case timeout
        case notSuccessful
    }
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SendAndWaitAsync.self)
    )
    
    public static func waitOnBoolResult(name: Notification.Name, timeout: Duration = .seconds(2), sendAction: @Sendable @escaping () async throws -> Void) async throws {
        enum TaskResult {
            case sent, received, cancelled
        }
        
        try await withThrowingTaskGroup(of: TaskResult.self) { group in
            group.addTask {
                let notification = await NotificationCenter.default.notifications(named: name).makeAsyncIterator().next()
                guard !Task.isCancelled else { return .cancelled }
                let value = notification?.userInfo?[Notification.Keys.value] as? Bool ?? false
                guard value else { throw WaitError.notSuccessful }
                Self.logger.info("Response on \(name.rawValue)")
                return .received
            }
                            
            group.addTask {
                try await Task.sleep(for: timeout)
                Self.logger.error("Timeout of \(name.rawValue)")
                throw WaitError.timeout
            }
            
            group.addTask {
                try await sendAction()
                Self.logger.info("Request for \(name.rawValue)")
                return .sent
            }
            
            do {
                for try await result in group {
                    if result == .received {
                        group.cancelAll()
                    }
                }
            }
            catch(_ as CancellationError) {
                // Intentionally empty.
            }
        }
    }
}
