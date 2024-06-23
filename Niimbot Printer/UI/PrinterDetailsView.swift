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
        @Bindable var details = details
        GroupBox() {
            VStack(alignment: .leading) {
                add(title: "Serial number", value: $details.serialNumber)
                Divider().padding(.horizontal)

                add(title: "Software version", value: $details.softwareVersion)
                Divider().padding(.horizontal)

                add(title: "Device type", value: $details.deviceType)
                Divider().padding(.horizontal)

                add(title: "Paper inserted", value: $details.isPaperInserted)
                Divider().padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Battery level").font(.caption)
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            LevelIndicator(segments: 3, level: $details.batteryLevel, warningRange: 2...2, errorRange:  1...1).containerRelativeFrame(.horizontal) { size, axis in
                                if axis == .horizontal { return size * 0.25 }
                                return size
                            }
                        }
                    }
                }
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

struct PrinterDetailsPreview: PreviewProvider {
    static var previews: some View {
        PrinterDetailsView().environmentObject(PrinterDetails())
    }
}

#Preview {
    PrinterDetailsPreview.previews
}
