//
//  FontSelectionView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 18.06.2024.
//

import SwiftUI
import AppKit

struct FontSelectionView: View {
    struct FontName: Identifiable {
        var id: String
    }
    
    let allFontNames: [FontName] = { () -> [FontName] in
        return NSFontManager.shared.availableFonts.map { (name) -> FontName in
            return FontName(id: name)
        }
    }()
    
    var allFontNamesForFamily: [FontName]  {
        var result: [FontName] = []
        guard let members = NSFontManager.shared.availableMembers(ofFontFamily: familySelection) else { return result }
        for item in members {
            result.append(FontName(id: item.first! as! String))
        }
        return result
    }
    
    let allFontFamilies: [FontName] = { () -> [FontName] in
        return NSFontManager.shared.availableFontFamilies.map { (name) -> FontName in
            return FontName(id: name)
        }
    }()
    
    @Binding var fontSelection: String
    @Binding var familySelection: String
    @Binding var fontSize: Int
    
    init(fontSelection: Binding<String>, familySelection: Binding<String>, fontSize: Binding<Int>) {
        self._fontSelection = fontSelection
        self._familySelection = familySelection
        self._fontSize = fontSize
    }
    
    var body: some View {
        GroupBox(){
            //            List(allFontFamilies, id: \.self) { name in
            //                Text(name).font(Font.custom(name, size: 12))
            //            }
            
            
            
            Form {
                Picker(selection: $familySelection) {
                    ForEach(allFontFamilies) { name in
                        Text(name.id).tag(name.id).font(Font.custom(name.id, size: 12))
                    }
                } label: {
                    Text("Font family").font(.headline)
                }
                .onChange(of: familySelection, initial: true) {
                    fontSelection = allFontNamesForFamily.first?.id ?? ""
                }.padding(.horizontal)
                
                Picker(selection: $fontSelection) {
                    ForEach(allFontNamesForFamily) { name in
                        Text(name.id).tag(name.id).font(Font.custom(name.id, size: 12, relativeTo: .title))
                    }
                } label: {
                    Text("Font variant").font(.headline)
                }.padding(.horizontal)
                
                IndicatorValueSlider(value: $fontSize,
                                    minValue: 1,
                                    maxValue: 100,
                                    label: { Text("Font size").font(.headline) }).padding(.horizontal)
            }
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
