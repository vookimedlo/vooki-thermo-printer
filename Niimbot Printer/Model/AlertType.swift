//
//  AlertType.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 02.08.2024.
//

import Foundation

@MainActor
public enum AlertType: Int {
    case none, printError
    
    var title: String {
        switch self {
        case .printError: return "Error"
        case .none: return ""
        }
    }
    var message: String {
        switch self {
        case .printError: return "Cannot complete printing operation."
        case .none: return ""
        }
    }
}
