//
//  BinaryFloatingPointExtension.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 16.10.2025.
//

extension BinaryFloatingPoint {
    func rounded(toMultipleOf multiple: Int) -> Self {
        guard multiple != 0 else { return self }
        return (self / Self(multiple)).rounded(.down) * Self(multiple)
    }
}
