//
//  PrinterLabelDetailView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI

struct PrinterLabelDetailView: View {
    @Environment(PaperDetails.self) private var details

    var body: some View {
        @Bindable var details = details
        GroupBox {
            VStack(alignment: .leading) {
                add(title: "Number of remaining labels", value: $details.remainingCount)
                    .animation(.smooth, value: details.remainingCount)
                Divider().padding(.horizontal)

                add(title: "Number of printed labels", value: $details.printedCount)
                    .animation(.smooth, value: details.printedCount)
                Divider().padding(.horizontal)

                add(title: "Serial number", value: $details.serialNumber)
                Divider().padding(.horizontal)

                add(title: "Barcode", value: $details.barcode)
                Divider().padding(.horizontal)

                add(title: "Type", value: $details.type)
            }
        }
        .animation(.easeIn(duration: 2), value: details.remainingCount)
        .animation(.easeIn(duration: 2), value: details.printedCount)
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
    static var previews: some View {
        PrinterLabelDetailView().environmentObject(PaperDetails())
    }
}

#Preview {
    PrinterLabelDetailPreview.previews
}
