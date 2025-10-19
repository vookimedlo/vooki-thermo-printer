/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public protocol FileSystemAccess {
    func open(_ path: UnsafePointer<CChar>, _ oflag: Int32) -> Int32
    
    @discardableResult
    func close(_ fileDescriptor: Int32) -> Int32
    func read(_ fileDescriptor: Int32, _ buffer: UnsafeMutableRawPointer!, _ count: Int) -> Int
    func write(_ fileDescriptor: Int32, _ buffer: UnsafeRawPointer!, _ count: Int) -> Int
}
