//
//  ContentView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI
import SwiftData


struct ContentView: View, Notifiable {
    
    enum Views {
        case printerView
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
    let historicalView = HistoryView()

    @ViewBuilder
    func getView(id: Views) -> some View {
        switch id {
        case .printerView: printerView
        case .historicalView: historicalView
        }
    }
    
    let items: [LitsItem] = [LitsItem(id: .printerView, systemName: "printer", description: "D110 Printer"),
                             LitsItem(id: .historicalView, systemName: "book.closed", description: "History")]
    
    @Environment(PrinterAvailability.self) private var printerAvailability
    @Environment(ConnectionViewProperties.self) private var connectionViewProperties
    
    @State var selectedItem: Views = .printerView
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .printError
    
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
                                .foregroundStyle(.green)
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
}

#Preview {
    ContentView()
        .modelContainer(for: SDLabelProperty.self, inMemory: true)
        .environmentObject(BluetoothPeripherals())
        .environmentObject(PrinterDetails())
        .environmentObject(PaperDetails())
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperEAN())
        .environmentObject(PrinterAvailability())
        .environmentObject(TextProperties())
        .environmentObject(ConnectionViewProperties())
}
