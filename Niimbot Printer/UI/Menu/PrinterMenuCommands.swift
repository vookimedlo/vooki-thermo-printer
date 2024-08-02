//
//  PrinterMenuCommands.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.08.2024.
//

import SwiftUI

struct PrinterMenuCommands: Commands, Notifiable {
    @Bindable var printerAvailability: PrinterAvailability
    @Bindable var connectionViewProperties: ConnectionViewProperties

    var body: some Commands {
        CommandMenu("Printer") {
            Menu(content: {
                Button(action: {
                    withAnimation {
                        connectionViewProperties.show = !connectionViewProperties.show
                    }
                }) {
                    Text("Search printers")
                }.disabled(printerAvailability.isConnected)
                Button(action: {
                    notifyUI(name: .App.lastSelectedPeripheral)
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
}
