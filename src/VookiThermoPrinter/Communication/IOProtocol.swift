/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public protocol IO {
    func open() throws
    func close()
    func readBytes(into buffer: UnsafeMutablePointer<UInt8>, size: Int) throws -> Int
    func writeBytes(from buffer: UnsafeRawPointer, size: Int) throws -> Int
    var name: String { get }
}
