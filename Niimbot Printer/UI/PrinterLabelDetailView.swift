//
//  PrinterLabelDetailView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI

struct PrinterLabelDetailView: View {
    @Binding var serialNumber: String
    @Binding var remainingCount: String
    @Binding var printedCount: String
    @Binding var barcode: String
    @Binding var type: String
    
    init(serialNumber: Binding<String>, remainingCount: Binding<String>, printedCount: Binding<String>, barcode: Binding<String>, type: Binding<String>) {
        self._serialNumber = serialNumber
        self._remainingCount = remainingCount
        self._printedCount = printedCount
        self._barcode = barcode
        self._type = type
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                add(title: "Number of remaining labels", value: $remainingCount)
                Divider().padding(.horizontal)

                add(title: "Number of printed labels", value: $printedCount)
                Divider().padding(.horizontal)

                add(title: "Serial number", value: $serialNumber)
                Divider().padding(.horizontal)

                add(title: "Barcode", value: $barcode)
                Divider().padding(.horizontal)

                add(title: "Type", value: $type)
            }
        }
    }
    
    private func add(title: String, value: Binding<String>) -> some View {
        return VStack(alignment: .leading) {
            Text(title).font(.caption)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("\(value.wrappedValue)").font(.footnote)
                }
            }
        }
    }
}

struct PrinterLabelDetailPreview: PreviewProvider {
    
    struct ContainerView: View {
        @State public var serialNumber: String = "N/A"
        @State public var remainingCount: String = "N/A"
        @State public var printedCount: String = "N/A"
        @State public var barcode: String = "N/A"
        @State public var type: String = "N/A"
        
        var body: some View {
            PrinterLabelDetailView(serialNumber: $serialNumber,
                                   remainingCount: $remainingCount,
                                   printedCount: $printedCount,
                                   barcode: $barcode,
                                   type: $type)
        }
    }

    static var previews: some View {
        ContainerView()
    }
}

#Preview {
    PrinterLabelDetailPreview.previews
}
