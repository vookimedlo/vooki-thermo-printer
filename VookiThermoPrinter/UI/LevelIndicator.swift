/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import SwiftUI


struct LevelIndicator : View {
    @Binding var level: Int
    
    let warningRange: ClosedRange<Int>
    let errorRange: ClosedRange<Int>

    let segmentCount: Double
    let segmentCountInt: Int

    let radius = 3.0
    let thickness = 2.0
    
    init(segments: Int, level: Binding<Int>, warningRange: ClosedRange<Int> = 0...0, errorRange: ClosedRange<Int> = 0...0) {
        segmentCount = Double(segments)
        segmentCountInt = segments
        _level = level
        self.warningRange = warningRange
        self.errorRange = errorRange
    }
    
    var levelColor : Color {
        switch level {
        case errorRange:
            return Color.red
        case warningRange:
            return Color.orange
        default:
            return Color.green
        }
    }
    
    var body: some View {
        ZStack() {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: radius)
                    .stroke(lineWidth: thickness)
                    .hidden()
                
                ForEach(0..<segmentCountInt, id: \.self) { i in
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(lineWidth: thickness)
                        .frame(width: geo.size.width / segmentCount)
                        .offset(x: (geo.size.width / segmentCount)  * Double(i))
                }

                ForEach(0..<level, id: \.self) { i in
                    RoundedRectangle(cornerRadius: radius)
                        .padding(thickness)
                        .shadow(radius: thickness)
                        .frame(width: geo.size.width / segmentCount)
                        .foregroundColor(levelColor)
                        .offset(x: (geo.size.width / segmentCount)  * Double(i))
                }
            }
        }
    }
}

#Preview {
    LevelIndicator(segments: 10, level: .constant(2), warningRange: 2...4)
}

