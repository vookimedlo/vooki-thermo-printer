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
    
    @State public var serialNumber: String = "N/A"
    @State public var softwareVersion: String = "N/A"
    @State public var deviceType: String = "N/A"
    @State public var isPaperInserted: String = "No"
    
    @State public var paperSerialNumber: String = "N/A"
    @State public var remainingCount: String = "N/A"
    @State public var printedCount: String = "N/A"
    @State public var barcode: String = "N/A"
    @State public var type: String = "N/A"
    
    @State private var showingInspector: Bool = true

    
    var body: some View {
        VStack {
            FontSelectionView(fontSelection: $fontSelection,
                              familySelection: $familySelection,
                              fontSize: $fontSize)
            
        }.inspector(isPresented: $showingInspector) {
                VStack(alignment: .center) {
                    Section("Printer properties") {
                            PrinterDetailsView(serialNumber: $serialNumber,
                                               softwareVersion: $softwareVersion,
                                               deviceType: $deviceType,
                                               isPaperInserted: $isPaperInserted)
                    }
                    
                    Section("Printer properties") {
                        PrinterLabelDetailView(serialNumber: $paperSerialNumber,
                                               remainingCount: $remainingCount,
                                               printedCount: $printedCount,
                                               barcode: $barcode,
                                               type: $type)
                    }
                    
                    
                    Text("test")
                }
        }.toolbar {
            
            ToolbarItem() {
                Button {
                    withAnimation {
                        showingInspector = !showingInspector
                    }
                } label: {
                    SwiftUI.Image(systemName: "sidebar.right")
                }
            }
            
        }
    }
}

#Preview {
    PrinterView()
}
