/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

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

