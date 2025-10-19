/****************************************************************************
VookiThermoPrinter - A lightweight macOS tool for printing to Niimbot label printers.
- https://github.com/vookimedlo/vooki-thermo-printer

  SPDX-FileCopyrightText: 2024 Michal Duda <github@vookimedlo.cz>
  SPDX-License-Identifier: GPL-3.0-or-later
  SPDX-FileType: SOURCE

****************************************************************************/

import SwiftUI
import AppKit

struct FontSelectionView: View {
    private struct FontName: Identifiable, Equatable, Sendable {
        var id: String
    }
    
    private let allFontNames: [FontName] = { () -> [FontName] in
        return NSFontManager.shared.availableFonts.map { (name) -> FontName in
            return FontName(id: name)
        }
    }()
    
    private var allFontNamesForFamily: [FontName]  {
        var result: [FontName] = []
        guard let members = NSFontManager.shared.availableMembers(ofFontFamily: familySelection) else { return result }
        for item in members {
            result.append(FontName(id: item.first! as! String))
        }
        return result
    }
    
    private let allFontFamilies: [FontName] = { () -> [FontName] in
        return NSFontManager.shared.availableFontFamilies.map { (name) -> FontName in
            return FontName(id: name)
        }
    }()
    
    @State private var isFontNamesForFamilyReady = false
    @State private var fontNamesForFamily: [FontName] = []
    
    @Binding private var fontSelection: String
    @Binding private var familySelection: String
    @Binding private var fontSize: Int
    
    init(fontSelection: Binding<String>, familySelection: Binding<String>, fontSize: Binding<Int>) {
        self._fontSelection = fontSelection
        self._familySelection = familySelection
        self._fontSize = fontSize
    }
    
    var body: some View {
        GroupBox {
            Form {
                Picker(selection: $familySelection) {
                    ForEach(allFontFamilies) { name in
                        Text(name.id).tag(name.id).font(Font.custom(name.id, size: 12))
                    }
                } label: {
                    Text("Font family").font(.headline)
                }.onChange(of: familySelection, initial: true) {
                    isFontNamesForFamilyReady = false
                    fontNamesForFamily = allFontNamesForFamily
                    fontSelection = fontNamesForFamily.first?.id ?? ""
                    isFontNamesForFamilyReady = true
                }.padding(.horizontal)
                
                if isFontNamesForFamilyReady {
                    Picker(selection: $fontSelection) {
                        ForEach(fontNamesForFamily) { name in
                            Text(name.id).tag(name.id).font(Font.custom(name.id, size: 12, relativeTo: .title))
                        }
                    } label: {
                        Text("Font variant").font(.headline)
                    }.padding(.horizontal)
                }
                
                IndicatorValueSlider(value: $fontSize,
                                    minValue: 1,
                                    maxValue: 100,
                                    label: { Text("Font size").font(.headline) }).padding(.horizontal)
            }.padding()
        } label: {
            Text("Font selection")
        }
    }
}

struct FontSelectionPreview: PreviewProvider {
    
    struct ContainerView: View {
        @State public var fontSelection: String = "Chalkboard"
        @State public var familySelection: String = "Chalkboard"
        @State public var fontSize: Int = 20
        
        var body: some View {
            FontSelectionView(fontSelection: $fontSelection, familySelection: $familySelection, fontSize: $fontSize)
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}

#Preview {
    FontSelectionPreview.previews
}

