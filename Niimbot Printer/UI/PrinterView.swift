//
//  PrinterView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI


struct PrinterView: View {
    @State public var fontSelection: String = "Chalkboard"
    @State public var familySelection: String = "Chalkboard"
    @State public var fontSize: Int = 20
    
    var body: some View {
        FontSelectionView(fontSelection: $fontSelection,
                          familySelection: $familySelection,
                          fontSize: $fontSize)
    }
}

#Preview {
    PrinterView()
}
