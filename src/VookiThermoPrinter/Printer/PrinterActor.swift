/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

@globalActor actor PrinterActor: GlobalActor {
    static let shared = PrinterActor()
    
    @PrinterActor
    static func onMain(_ operation: @escaping @autoclosure @Sendable @MainActor () -> Void?) {
        Task { @MainActor in
            operation()
        }
    }
    
    @MainActor
    static func printerOperation(_ operation: @escaping @Sendable @PrinterActor () throws -> Void?) async -> Bool {
        let task = Task { @PrinterActor in
            do {
                try operation()
                return true
            }
            catch {
                return false
            }
        }
        
        return await task.result.get()
    }
}
