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
    
    enum Views {
        case emptyView
        case printerView
        case savedView
        case historicalView
    }
    
    struct LitsItem : Identifiable {
        let id: Views
        let systemName: String
        let description: String
        
        init(id: Views, systemName: String, description: String) {
            self.id = id
            self.systemName = systemName
            self.description = description
        }
    }
    
    let printerView = PrinterView()
    let savedView = SavedView()
    let historicalView = HistoryView()

    @ViewBuilder
    func getView(id: Views) -> some View {
        switch id {
        case .emptyView: EmptyView()
        case .printerView: printerView
        case .savedView: savedView
        case .historicalView: historicalView
        }
    }
    
    @Environment(\.appDetails) private var appDetails
    
    var items: [LitsItem] {
        [
            LitsItem(id: .printerView, systemName: "printer", description: appDetails.printerVariant + " Printer"),
            LitsItem(id: .savedView, systemName: "tray", description: "Saved labels"),
            LitsItem(id: .historicalView, systemName: "book.closed", description: "History")
        ]
    }
    
    @Environment(PrinterAvailability.self) private var printerAvailability
    @Environment(ConnectionViewProperties.self) private var connectionViewProperties
    
    @State var selectedItem: Views = .emptyView
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .none
    
    var body: some View {
        @Bindable var connectionViewProperties = connectionViewProperties
        
        NavigationSplitView {
            List(selection: $selectedItem) {
                ForEach(items) { item in
                    NavigationLink {
                        getView(id: item.id)
                    } label: {
                        HStack {
                            SwiftUI.Image(systemName: item.systemName)
                                .resizable()
                                .symbolRenderingMode(.monochrome)
                                .symbolVariant(.fill)
                                .fontWeight(.regular)
                                .foregroundStyle(Color.lila)
                                .frame(width: 18, height: 18)
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                Text(item.description).padding(.bottom, 10)
                                Divider()
                            }
                        }
                    }.tag(item.id)
                }
            }
            .listRowSeparator(.hidden)
        } detail: {
        }
        .alert(Text(alertType.title),
                isPresented: $showAlert,
                actions: {
                    Button("OK") {
                        showAlert = false;
                        alertType = .none
                    }
                }, message: {
                    Text(alertType.message)
                }
            )
        .onReceive(NotificationCenter.default.publisher(for: .App.UI.alert)) { notification  in
            alertType = notification.userInfo?[Notification.Keys.value] as! AlertType
            withAnimation {
                showAlert = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .App.showView)) { notification  in
            let viewType = notification.userInfo?[Notification.Keys.value] as! Views
            withAnimation {
                selectedItem = viewType
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
        .task {
            try? await Task.sleep(nanoseconds: 10)
            selectedItem = .printerView
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SDHistoryLabelProperty.self, inMemory: true, isAutosaveEnabled: false)
        .environmentObject(BluetoothPeripherals())
        .environmentObject(PrinterDetails())
        .environmentObject(PaperDetails())
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperEAN())
        .environmentObject(PrinterAvailability())
        .environmentObject(TextProperties())
        .environmentObject(ConnectionViewProperties())
}

