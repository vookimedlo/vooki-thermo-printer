//
//  PrinterView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI
import AppKit


struct PrinterView: View {
    
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
    
    @State var fontSelection: String = "Chalkboard"
    @State var familySelection: String = "Chalkboard"
    
    @State var fontSize: Int = 2
    
    var body: some View {
        GroupBox(){
            //            List(allFontFamilies, id: \.self) { name in
            //                Text(name).font(Font.custom(name, size: 12))
            //            }
            
            
            
            Form {
                Picker(selection: $familySelection) {
                    ForEach(allFontFamilies) { name in
                        Text(name.id).font(Font.custom(name.id, size: 12))
                    }
                } label: {
                    Text("Font family").font(.headline)
                }
                .onChange(of: familySelection, initial: true) {
                    fontSelection = allFontNamesForFamily.first?.id ?? ""
                }.padding(.horizontal)
                
                
                Picker(selection: $fontSelection) {
                    ForEach(allFontNamesForFamily) { name in
                        Text(name.id).font(Font.custom(name.id, size: 12, relativeTo: .title))
                    }
                } label: {
                    Text("Font variant").font(.headline)
                }.padding(.horizontal)
                
                Slider(value: Binding(get: { Double(fontSize) },
                                      set: { newValue in
                    let base: Int = Int(newValue.rounded())
                    let modulo: Int = base % 1
                    fontSize = base - modulo
                }),
                       in: 1...100,
                       minimumValueLabel: Text("1"),
                       maximumValueLabel: Text("100"),
                       label: {
                    Text("Font size").font(.headline)
                }
                ).padding(.horizontal)
                
            
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

#Preview {
    PrinterView()
}
