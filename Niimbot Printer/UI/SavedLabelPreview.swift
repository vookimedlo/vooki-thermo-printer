//
//  SavedLabelPreview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.08.2024.
//

import SwiftUI

struct SavedLabelPreview: View {
    let savedLabelProperty: SavedLabelProperty
    
    var body: some View {
        VStack {
            Image(nsImage: NSImage(data: self.savedLabelProperty.pngImage)!).shadow(color: .orange, radius: 30)
            HStack {
                Form(content: {
                    LabeledContent("Date:") {
                        Text(self.savedLabelProperty.date.formatted())
                    }
                    LabeledContent("Label EAN:") {
                        Text(self.savedLabelProperty.paperEANRawValue)
                    }
                    LabeledContent("Label type:") {
                        Text("\(PaperEAN(rawValue: self.savedLabelProperty.paperEANRawValue)?.description ?? "")")
                    }
                    LabeledContent("Layers:") {
                        Text("\(self.savedLabelProperty.textProperties.count)")
                    }
                })
            }
        }
    }
}

//#Preview {
//    SavedLabelPreview(savedLabelProperty: SavedLabelProperty())
//}
