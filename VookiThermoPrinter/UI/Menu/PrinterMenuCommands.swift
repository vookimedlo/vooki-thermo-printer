//
//  PrinterMenuCommands.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.08.2024.
//

import SwiftUI

struct PrinterMenuCommands: Commands, StaticNotifiable {
    @Bindable var printerAvailability: PrinterAvailability
    @Bindable var connectionViewProperties: ConnectionViewProperties

    var body: some Commands {
        CommandMenu("Printer") {
            Self.connectMenu(printerAvailability: printerAvailability,
                             connectionViewProperties: connectionViewProperties)
            Self.disconnectMenu(printerAvailability: printerAvailability)
        }
    }
    
    @ViewBuilder
    static func connectMenu(@Bindable printerAvailability: PrinterAvailability, @Bindable connectionViewProperties: ConnectionViewProperties) -> some View {
        Menu(content: {
            Button(action: {
                withAnimation {
                    connectionViewProperties.show = !connectionViewProperties.show
                }
            }) {
                Text("Search printers")
            }.disabled(printerAvailability.isConnected)
            Button(action: {
                Self.notifyUI(name: .App.lastSelectedPeripheral)
            }) {
                Text("Last printer")
            }.disabled(!printerAvailability.isAvailable || printerAvailability.isConnected)
        }, label: {
            SwiftUI.Image(systemName: "antenna.radiowaves.left.and.right")
                .symbolRenderingMode(.palette)
                .fontWeight(.regular)
                .foregroundStyle(.green)
            Text("Connect ...")
        })
        .disabled(printerAvailability.isConnected)
    }
    
    @ViewBuilder
    static func disconnectMenu(@Bindable printerAvailability: PrinterAvailability) -> some View {
        Button(action: {
            notifyUI(name: .App.disconnectPeripheral)
        }, label: {
            SwiftUI.Image(systemName: "antenna.radiowaves.left.and.right")
                .symbolRenderingMode(.palette)
                .fontWeight(.regular)
                .foregroundStyle(.red)
            Text("Disconnect")
        }).disabled(!printerAvailability.isConnected)
    }
}
