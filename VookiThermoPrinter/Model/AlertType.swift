//
//  AlertType.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 02.08.2024.
//

import Foundation

@MainActor
public enum AlertType: Int, Sendable {
    case none, printError, communicationError
    
    var title: String {
        switch self {
        case .communicationError: "Error"
        case .printError: "Error"
        case .none: ""
        }
    }
    var message: String {
        switch self {
        case .communicationError: return "Cannot communicate with the printer."
        case .printError: return "Unable to complete the print operation."
        case .none: return ""
        }
    }
}
