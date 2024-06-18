//
//  PrinterDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI

struct PrinterDetailsView: View {
    @Binding var serialNumber: String
    @Binding var softwareVersion: String
    @Binding var deviceType: String
    @Binding var isPaperInserted: String

    
    init(serialNumber: Binding<String>, softwareVersion: Binding<String>, deviceType: Binding<String>, isPaperInserted: Binding<String>) {
        self._serialNumber = serialNumber
        self._softwareVersion = softwareVersion
        self._deviceType = deviceType
        self._isPaperInserted = isPaperInserted
    }
    
    var body: some View {
        GroupBox{
            add(title: "Serial number", value: $serialNumber).padding(.horizontal).padding(.bottom, 5)
            add(title: "Software version", value: $softwareVersion).padding(.horizontal).padding(.bottom, 5)
            add(title: "Device type", value: $deviceType).padding(.horizontal).padding(.bottom, 5)
            add(title: "Paper inserted", value: $isPaperInserted).padding(.horizontal)
        }
    }
    
    private func add(title: String, value: Binding<String>) -> some View {
        return LabeledContent {
            Text("\(value.wrappedValue)")
        } label: {
            Text(title).font(.headline)
        }
    }
}

struct PrinterDetailsPreview: PreviewProvider {
    
    struct ContainerView: View {
        @State public var serialNumber: String = "N/A"
        @State public var softwareVersion: String = "N/A"
        @State public var deviceType: String = "N/A"
        @State public var isPaperInserted: String = "No"
        
        var body: some View {
            PrinterDetailsView(serialNumber: $serialNumber,
                               softwareVersion: $softwareVersion,
                               deviceType: $deviceType,
                               isPaperInserted: $isPaperInserted)
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}

#Preview {
    PrinterDetailsPreview.previews
}
