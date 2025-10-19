/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import Foundation

public protocol BluetoothAccess {
    func open() throws
    func close()
    func write(from buffer: UnsafeRawPointer, size: Int) throws -> Int
    var name: String { get }
    
    func replaceConsumer(dataConsumer: DataConsumer)
}

