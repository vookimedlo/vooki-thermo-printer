/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import XCTest
@testable import VookiThermoPrinter___D110

final class SendAndWaitAsyncTests: XCTestCase {
    func testWaitOnBoolResult_Timeout() async {
        let timeout = 2
        
        do {
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.allowPrintClear,
                                                        timeout: .seconds(timeout),
                                                        sendAction: {
                try await Task.sleep(for: .seconds(timeout - 1))
            })
        }
        catch SendAndWaitAsync.WaitError.timeout {
            return
        }
        catch {}
        XCTFail("Timeout hasn't occurred.")
    }
    
    func testWaitOnBoolResult_TimeoutCancelsConcurrentTask() async {
        let timeout = 1
        let start = DispatchTime.now()
        do {
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.allowPrintClear,
                                                        timeout: .seconds(timeout),
                                                        sendAction: {
                try await Task.sleep(for: .seconds(timeout * 30))
            })
        }
        catch SendAndWaitAsync.WaitError.timeout {
            let distance: DispatchTimeInterval = start.distance(to: DispatchTime.now())
            if case .nanoseconds(let value) = distance {
                XCTAssertEqual(UInt64(value) / NSEC_PER_SEC, UInt64(timeout))
                return
            }
        }
        catch {}
        XCTFail("Timeout hasn't cancelled the concurrent task.")
    }
    
    func testWaitOnBoolResult_TrueNotificationReceived() async {
        let timeout = 5
        do {
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.allowPrintClear,
                                                        timeout: .seconds(timeout),
                                                        sendAction: {
                NotificationCenter.default.post(name: Notification.Name.App.allowPrintClear,
                                                object: nil,
                                                userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, true)))
            })
        }
        catch {
            XCTFail("Timeout hasn't cancelled the concurrent task.")
        }
    }
    
    func testWaitOnBoolResult_FalseNotificationReceived() async {
        let timeout = 5
        do {
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.allowPrintClear,
                                                        timeout: .seconds(timeout),
                                                        sendAction: {
                NotificationCenter.default.post(name: Notification.Name.App.allowPrintClear,
                                                object: nil,
                                                userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, false)))
            })
        }
        catch SendAndWaitAsync.WaitError.notSuccessful {
            return
        }
        catch {}
        XCTFail("Timeout hasn't cancelled the concurrent task.")
    }

    func testWaitOnBoolResult_WrongTypeeNotificationReceived() async {
        let timeout = 5
        do {
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.allowPrintClear,
                                                        timeout: .seconds(timeout),
                                                        sendAction: {
                NotificationCenter.default.post(name: Notification.Name.App.allowPrintClear,
                                                object: nil,
                                                userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, 8.0)))
            })
        }
        catch SendAndWaitAsync.WaitError.notSuccessful {
            return
        }
        catch {}
        XCTFail("Timeout hasn't cancelled the concurrent task.")
    }
}
