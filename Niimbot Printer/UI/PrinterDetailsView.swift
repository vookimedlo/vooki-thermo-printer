//
//  PrinterDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI

struct PrinterDetailsView: View {
    @Environment(PrinterDetails.self) private var details
    
    var body: some View {
        GroupBox() {
            VStack(alignment: .leading) {
                add(title: "Serial number", value: details.serialNumber)
                Divider().padding(.horizontal)

                add(title: "Software version", value: details.softwareVersion)
                Divider().padding(.horizontal)

                add(title: "Device type", value: details.deviceType)
                Divider().padding(.horizontal)

                add(title: "Paper inserted", value: details.isPaperInserted)
            }
        }
    }
    
    private func add(title: String, value: String) -> some View {
        return VStack(alignment: .leading) {
            Text(title).font(.caption)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("\(value)").font(.footnote)
                }
            }
        }
    }
}

struct PrinterDetailsPreview: PreviewProvider {
    
    struct ContainerView: View {
        var body: some View {
            PrinterDetailsView()
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}

#Preview {
    PrinterDetailsPreview.previews
}
