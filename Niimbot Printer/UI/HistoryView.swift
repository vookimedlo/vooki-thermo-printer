//
//  HistoryView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 13.06.2024.
//

import SwiftUI

struct HistoryView: View, StaticNotifiable {
    @Environment(SavedLabelProperties.self) private var savedLabelProperties
    
    struct Group: Identifiable {
        let id: String = UUID().uuidString
        var width: Double = 0
        var group: [SavedLabelProperty] = []
        var type: String = ""
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(processProperties(0..<savedLabelProperties.properties.count)) { group in
                    GroupBox(label: Text(group.type).font(.headline)) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: group.width + 20))]) {
                            ForEach(group.group) { item in
                                SavedLabelPreview(savedLabelProperty: item).padding(.top)
                                    .contextMenu {
                                        Button(action: {
                                            let data = [String: Sendable](dictionaryLiteral: (Notification.Keys.value, item))
                                            Self.notifyUI(name: .App.loadHistoricalItem,
                                                          userInfo: data)
                                        }) {
                                            Label("Load", systemImage: "tray.and.arrow.up").labelStyle(.titleAndIcon)
                                        }
                                        Button(action: {
                                            guard let url = showSavePanel() else { return }
                                            let imageRep = NSBitmapImageRep(data: item.pngImage)!
                                            let pngData = imageRep.representation(using: .png, properties: [:])!
                                            try! pngData.write(to: url)
                                        }) {
                                            Label("Save as PNG", systemImage: "tray.and.arrow.down").labelStyle(.titleAndIcon)
                                        }
                                    }
                            }
                        }
                    }.padding(.top)
                }
            }
        }.navigationTitle("History")
    }
    
    func processProperties(_ range: Range<Int>) -> [Group] {
        var dividedProperties: [Group] = []
        
        var lastImageWidth: Double = 0
        
        for index in range {
            guard let ean = PaperEAN(rawValue: self.savedLabelProperties.properties[index].paperEANRawValue) else { continue }
            let width = ean.printableSizeInPixels.width

            if lastImageWidth != width {
                dividedProperties.append(Group(width: width, type: ean.description))
            }
            dividedProperties[dividedProperties.count - 1].group.insert(self.savedLabelProperties.properties[index], at: 0)
            lastImageWidth = width
        }
        return dividedProperties.reversed()
    }

    func showSavePanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes  = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden    = false
        savePanel.title                = "Save rendered image..."
        savePanel.nameFieldLabel       = "Filename:"
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
}

#Preview {
    HistoryView()
}
