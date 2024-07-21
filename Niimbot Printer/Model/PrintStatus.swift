//
//  PrintStatus.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 21.07.2024.
//


public struct PrintStatus: Sendable, Equatable {
    public init(page: UInt16, progress1: UInt8, progress2: UInt8) {
        self.page = page
        self.progress1 = progress1
        self.progress2 = progress2
    }
    
    let page: UInt16
    let progress1: UInt8
    let progress2: UInt8
}
