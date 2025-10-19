//
//  VerticalLine.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 13.08.2024.
//

import SwiftUI

struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minY, y: rect.minY))

        return path
    }
}
