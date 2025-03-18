//
//  PrinterDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI

struct PrinterDetailsView: View {
    @Environment(PrinterDetails.self) private var details
    @Environment(PrinterAvailability.self) private var availability
    
    let pristineDetails = PrinterDetails()

    var body: some View {
        @Bindable var details = details
        @Bindable var availability = availability
        GroupBox() {
            VStack(alignment: .leading) {
                add(title: "Printer connected", value: $availability.isConnected)
                if availability.isConnected {
                    Divider().padding(.horizontal)
                    add(title: "Name", value: $details.name)
                    
                    if pristineDetails.deviceType != details.deviceType {
                        Divider().padding(.horizontal)
                        add(title: "Type", value: $details.deviceType)
                    }
                    
                    if pristineDetails.serialNumber != details.serialNumber {
                        Divider().padding(.horizontal)
                        add(title: "Serial number", value: $details.serialNumber)
                    }

                    if pristineDetails.softwareVersion != details.softwareVersion {
                        Divider().padding(.horizontal)
                        add(title: "Software version", value: $details.softwareVersion)
                    }

                    if pristineDetails.batteryLevel != details.batteryLevel {
                        Divider().padding(.horizontal)
                        VStack(alignment: .leading) {
                            Text("Battery level").font(.caption)
                            VStack(alignment: .trailing) {
                                HStack {
                                    Spacer()
                                    LevelIndicator(segments: 4, level: $details.batteryLevel, warningRange: 2...2, errorRange:  1...1).containerRelativeFrame(.horizontal) { size, axis in
                                        if axis == .horizontal { return size * 0.25 }
                                        return size
                                    }
                                }
                            }.animation(.smooth, value: details.batteryLevel)
                        }
                    }
                    
                    Divider().padding(.horizontal)
                    add(title: "Paper inserted", value: $details.isPaperInserted)
                }
            }
            .animation(.smooth, value: details.serialNumber)
            .animation(.smooth, value: details.softwareVersion)
            .animation(.smooth, value: details.deviceType)
        }
    }
    
    @ViewBuilder
    private func add(title: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("\(value.wrappedValue)").font(.footnote)
                }
            }
        }
    }
    
    @ViewBuilder
    private func add(title: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("\(value.wrappedValue ? "Yes" : "No")").font(.footnote)
                }
            }
        }
    }
}

struct PrinterDetailsPreview: PreviewProvider {
    static var previews: some View {
        PrinterDetailsView()
            .environmentObject(PrinterDetails())
            .environmentObject(PrinterAvailability())
    }
}

#Preview {
    PrinterDetailsPreview.previews
}
