//
//  ContentView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
