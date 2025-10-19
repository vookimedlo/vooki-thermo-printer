/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

struct RFIDData: Sendable, Equatable {
    let uuid: [UInt8]
    let barcode: String
    let serial: String
    let totalLength: UInt16
    let usedLength: UInt16
    let type: UInt8
}
