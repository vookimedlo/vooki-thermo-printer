/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import SwiftUI
import SwiftData

struct ContentView: View, Notifiable {
    @Environment(PrinterDetails.self) private var printerDetails
    @Environment(PrinterAvailability.self) private var printerAvailability
    @Environment(ConnectionViewProperties.self) private var connectionViewProperties
    @Environment(\.appDetails) private var appDetails

    @State private var showingInspector: Bool = true
    @State private var showingPrintingProgress: Bool = false

    enum Views: Hashable {
        case emptyView
        case printerView
        case savedView
        case historicalView
    }

    struct LitsItem: Identifiable {
        let id: Views
        let systemName: String
        let description: String
    }

    let printerView = PrinterView()
    let savedView = SavedView()
    let historicalView = HistoryView()

    @State private var selectedItem: Views? = .emptyView

    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .none

    // přidáme, ať vidíš, kdy je sidebar schovaný
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var items: [LitsItem] {
        [
            LitsItem(id: .printerView, systemName: "printer", description: appDetails.printerVariant + " Printer"),
            LitsItem(id: .savedView, systemName: "tray", description: "Saved labels"),
            LitsItem(id: .historicalView, systemName: "book.closed", description: "History")
        ]
    }

    @ViewBuilder
    func getView(id: Views) -> some View {
        switch id {
        case .emptyView: EmptyView()
        case .printerView: printerView
        case .savedView: savedView
        case .historicalView: historicalView
        }
    }

    var body: some View {
        @Bindable var connectionViewProperties = connectionViewProperties

        ZStack {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                List(items, selection: $selectedItem) { item in
                    HStack {
                        Image(systemName: item.systemName)
                            .resizable()
                            .symbolRenderingMode(.monochrome)
                            .symbolVariant(.fill)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.lila)
                            .frame(width: 18, height: 18)
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                            Text(item.description)
                                .padding(.bottom, 10)
                            Divider()
                        }
                    }
                    .tag(item.id as Views?)
                }
                .listRowSeparator(.hidden)
            } detail: {
                if let selectedItem {
                    getView(id: selectedItem)
                } else {
                    EmptyView()
                }
            }
            .inspector(isPresented: $showingInspector) {
                VStack {
                    List {
                        Section(header: Text("Printer")) {
                            PrinterDetailsView()
                        }
                        if printerAvailability.isConnected && printerDetails.isPaperInserted {
                            Section(header: Text("Paper")) {
                                PrinterLabelDetailView()
                            }
                        }
                    }
                    .listStyle(.sidebar)
                    Spacer()
                }
                .animation(.easeInOut, value: printerAvailability.isConnected)
                .animation(.easeInOut, value: printerDetails.isPaperInserted)
            }
            .sheet(isPresented: $showingPrintingProgress) {
                VStack {
                    Text("Printing ...").padding(.top)
                    Divider()
                    HStack {
                        Spacer()
                        PrintingProgress()
                        Spacer()
                    }.padding()
                }
                .frame(minWidth: 600)
                .interactiveDismissDisabled()
            }
            .toolbar {
                ToolbarItem() {
                    Button {
                        withAnimation {
                            showingInspector.toggle()
                        }
                    } label: {
                        SwiftUI.Image(systemName: "sidebar.right")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .appBar) {
                    PrinterMenuCommands.connectMenu(printerAvailability: printerAvailability,
                                                    connectionViewProperties: connectionViewProperties)
                        .popover(isPresented: $connectionViewProperties.show) {
                            BluetoothPeripheralsView(isPresented: $connectionViewProperties.show)
                        }
                }
                ToolbarItem(placement: .appBar) {
                    PrinterMenuCommands.disconnectMenu(printerAvailability: printerAvailability)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .App.UI.printStarted)) { _ in
            withAnimation { showingPrintingProgress = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: .App.UI.printDone)) { _ in
            withAnimation { showingPrintingProgress = false }
        }
        .onReceive(NotificationCenter.default.publisher(for: .App.UI.alert)) { notification  in
            let alert = notification.userInfo?[Notification.Keys.value] as! AlertType
            alertType = alert
            withAnimation { showAlert = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: .App.showView)) { notification  in
            guard let viewType = notification.userInfo?[Notification.Keys.value] as? Views else {
                return
            }
            withAnimation {
                selectedItem = viewType
            }
        }
        .alert(Text(alertType.title),
               isPresented: $showAlert,
               actions: {
                    Button("OK") {
                        showAlert = false
                        alertType = .none
                    }
               }, message: {
                    Text(alertType.message)
               }
        )
        .task {
            try? await Task.sleep(for: .nanoseconds(50))
            await MainActor.run {
                selectedItem = .printerView
            }
        }
    }
}
