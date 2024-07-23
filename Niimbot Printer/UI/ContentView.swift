//
//  ContentView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI
import SwiftData

@MainActor
public enum AlertType: Int {
    case none, printError
    
    var title: String {
        switch self {
        case .printError: return "Error"
        case .none: return ""
        }
    }
    var message: String {
        switch self {
        case .printError: return "Cannot complete printing operation."
        case .none: return ""
        }
    }
}


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
    
    @State var selectedItem: Views = .printerView
    @State var showConnectionView: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .printError
    
    var body: some View {
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
                Menu(content: {
                    Button(action: {
                        withAnimation {
                            showConnectionView = !showConnectionView
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
                .popover(isPresented: $showConnectionView) {
                    BluetoothPeripheralsView(isPresented: $showConnectionView)
                }
            }
            ToolbarItem(placement: .appBar) {
                Button (action: {
                    notifyUI(name: Notification.Name.App.disconnectPeripheral)
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
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(BluetoothPeripherals())
        .environmentObject(PrinterDetails())
        .environmentObject(PaperDetails())
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperType())
        .environmentObject(PrinterAvailability())
        .environmentObject(TextProperties())
}

extension ToolbarItemPlacement {
    @MainActor static let appBar = accessoryBar(id: UUID().uuidString)
}
