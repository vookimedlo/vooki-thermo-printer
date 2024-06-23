//
//  ContentView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View, Notifier {
    
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
    
    @State var selectedItem: Views?
    @State var showConnectionView: Bool = false
    
    
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
            .onAppear { selectedItem = items.first?.id }
        } detail: {
            Text("asdads at uytut")
        }.toolbar {
            ToolbarItem(placement: .appBar) {
                
                Menu(content: {
                    Button(action: {
                        withAnimation {
                            showConnectionView = !showConnectionView
                        }
                    }) {
                        Text("Search printers")
                    }
                    Button(action: {
                        // TODO
                    }) {
                        Text("Last printer")
                    }
                }, label: {
                    SwiftUI.Image(systemName: "antenna.radiowaves.left.and.right")
                        .symbolRenderingMode(.palette)
                        .fontWeight(.regular)
                        .foregroundStyle(.green)
                    Text("Connect ...")
                }).popover(isPresented: $showConnectionView) {
                    BluetoothPeripheralsView(isPresented: $showConnectionView)
                }
            }
            ToolbarItem(placement: .appBar) {
                Button (action: {
                    notify(name: Notifications.Names.disconnectPeripheral)
                }, label: {
                    SwiftUI.Image(systemName: "antenna.radiowaves.left.and.right")
                        .symbolRenderingMode(.palette)
                        .fontWeight(.regular)
                        .foregroundStyle(.red)
                    Text("Disconnect")
                })
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(PrinterDetails())
        .environmentObject(PaperDetails())
}

extension ToolbarItemPlacement {
    static let appBar = accessoryBar(id: UUID().uuidString)
}
