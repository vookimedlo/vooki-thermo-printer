/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2025 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

extension BinaryFloatingPoint {
    func rounded(toMultipleOf multiple: Int) -> Self {
        guard multiple != 0 else { return self }
        return (self / Self(multiple)).rounded(.down) * Self(multiple)
    }
}
