//
//  PrinterActor.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 18.07.2024.
//


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
