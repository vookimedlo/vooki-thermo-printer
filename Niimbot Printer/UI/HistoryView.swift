//
//  HistoryView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 13.06.2024.
//

import SwiftUI
import SwiftData


struct HistoryView: View, StaticNotifiable {
    @Environment(\.modelContext) var context
    @Query(sort: \SDHistoryLabelProperty.date, order: SortOrder.reverse) var labelProperties: [SDHistoryLabelProperty]
    
    struct Group: Identifiable {
        let id: String = UUID().uuidString
        var width: Double = 0
        var group: [SDHistoryLabelProperty] = []
        var type: String = ""
    }
    
    var body: some View {
        VStack {
            if (labelProperties.count != 0) {
                ScrollView {
                    ForEach(processProperties(0..<labelProperties.count)) { group in
                        GroupBox(label: Text(group.type).font(.headline)) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: group.width + 20))]) {
                                ForEach(group.group) { item in
                                    SavedLabelPreview(savedLabelProperty: item).padding(.top)
                                        .contextMenu {
                                            Button(action: {
                                                let data = [String: Sendable](dictionaryLiteral: (Notification.Keys.value, item.id))
                                                Self.notifyUI(name: .App.loadHistoricalItem,
                                                              userInfo: data)
                                            }) {
                                                Label("Load", systemImage: "tray.and.arrow.up").labelStyle(.titleAndIcon)
                                            }
                                            Button(action: {
                                                context.insert(SDSavedLabelProperty(from: item))
                                            }) {
                                                Label("Add to saved labels", systemImage: "tray").labelStyle(.titleAndIcon)
                                            }
                                            Button(action: {
                                                guard let url = showSavePNGPanel() else { return }
                                                let imageRep = NSBitmapImageRep(data: item.pngImage)!
                                                let pngData = imageRep.representation(using: .png, properties: [:])!
                                                try! pngData.write(to: url)
                                            }) {
                                                Label("Export as PNG", systemImage: "tray.and.arrow.down").labelStyle(.titleAndIcon)
                                            }
                                            Button(action: {
                                                guard let url = showSaveJSONPanel() else { return }
                                                let encodedData = encodeToJSON(item: item)
                                                print("CBOR: \(encodedData.hexEncodedString())")
                                                try! encodedData.write(to: url)
                                            }) {
                                                Label("Export as JSON", systemImage: "tray.and.arrow.down").labelStyle(.titleAndIcon)
                                            }
                                            Button(action: {
                                                self.context.delete(item)
                                            }) {
                                                Label("Delete", systemImage: "trash").labelStyle(.titleAndIcon)
                                            }
                                        }
                                }
                            }
                        }.padding(.top)
                    }
                }
            }
            else {
                ContentUnavailableView {
                    Label("Printing history", systemImage: "book.closed")
                } description: {
                    Text("This secion contains all labels that have been printed so far.")
                }
            }
        }
        .navigationTitle("History")
    }
    
    func encodeToJSON(item: SDHistoryLabelProperty) -> Data {
        guard let textProperties = item.orderedTextProperties else { return Data() }

        var properties: [SendableTextProperty] = []
        for textProperty in textProperties {
            properties.append(SendableTextProperty(from: (textProperty.toTextProperty())))
        }
        
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(properties) else { return Data() }
        return encodedData
    }
    
    func processProperties(_ range: Range<Int>) -> [Group] {
        var dividedProperties: [Group] = []
        var lastImageWidth: Double = 0
        
        for index in range {
            guard let ean = PaperEAN(rawValue: self.labelProperties[index].paperEANRawValue) else { continue }
            let width = ean.printableSizeInPixels.width

            if lastImageWidth != width {
                dividedProperties.append(Group(width: width, type: ean.description))
            }
            dividedProperties[dividedProperties.count - 1].group.append(self.labelProperties[index])
            lastImageWidth = width
        }
        return dividedProperties
    }

    func showSavePNGPanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes  = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden    = false
        savePanel.title                = "Save a rendered image..."
        savePanel.nameFieldLabel       = "Filename:"
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
    
    func showSaveJSONPanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes  = [.json]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden    = false
        savePanel.title                = "Save a JSON data..."
        savePanel.nameFieldLabel       = "Filename:"
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: SDHistoryLabelProperty.self, inMemory: true, isAutosaveEnabled: false)
}
