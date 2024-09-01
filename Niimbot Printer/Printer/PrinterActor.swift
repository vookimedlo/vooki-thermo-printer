//
//  PrinterActor.swift
//  Niimbot Printer
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
    
}
