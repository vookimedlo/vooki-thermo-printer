//
//  IOError.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 30.05.2024.
//

import Foundation

enum IOError: Error {
    case open
    case read
    case write
}
