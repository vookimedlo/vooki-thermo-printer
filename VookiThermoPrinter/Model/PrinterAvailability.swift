//
//  PrinterAvailability.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 05.07.2024.
//

import Foundation

@MainActor
@Observable
final class PrinterAvailability: ObservableObject {
    var isAvailable: Bool = false
    var isConnected: Bool = false
}
