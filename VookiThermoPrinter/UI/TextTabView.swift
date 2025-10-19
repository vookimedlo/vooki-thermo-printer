//
//  TextTabView.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 06.07.2024.
//

import SwiftUI


struct TextTabView: View {
    @Environment(TextProperties.self) private var textProperties
    
    @Binding var selectedTextProperty: TextProperty?

    private let controlBackgroundColor = Color(NSColor.separatorColor)
    private let controlSelectedColor = Color(NSColor.selectedControlColor)
 
    @State var selectedTab = 0
 
    var body: some View {
        ZStack(alignment: .top) {
            GroupBox {
                HStack {
                    Spacer()
                    TextConstructionView().environmentObject(textProperties.properties[textProperties.properties.count > selectedTab ? selectedTab : 0])
                    Spacer()
                }.onChange(of: textProperties.properties.count) { oldValue, newValue in
                    if oldValue != newValue && newValue == 1 {
                        selectedTab = 0
                    }
                }
            }.padding(.top, 10)
            
            HStack(spacing: 0) {
                Spacer()
                ForEach(0..<textProperties.properties.count, id:\.self) {index in
                    Tab(label: "\(index + 1)", id: index)
                }
                NewTab(label: "+")
                Spacer()
            }
        }.onAppear() {
            selectedTextProperty = textProperties.properties[selectedTab]
        }
    }
}

extension TextTabView {
    @ViewBuilder
    func Tab(label: String, id: Int) -> some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 3)
                .fill(id == selectedTab ? controlSelectedColor : controlBackgroundColor)
                .frame(width: 20, height: 20)
            Text(label)
        }.gesture(TapGesture().onEnded({
            withAnimation {
                selectedTab = id
                selectedTextProperty = textProperties.properties[selectedTab]
            }
        }))
    }
    
    @ViewBuilder
    func NewTab(label: String) -> some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 3)
                .fill(controlBackgroundColor)
                .frame(width: 20, height: 20)
            Text(label)
        }.gesture(TapGesture().onEnded({
            textProperties.properties.append(TextProperty())
            withAnimation {
                selectedTab = textProperties.properties.count - 1
                selectedTextProperty = textProperties.properties[selectedTab]
            }
        }))
    }
}

#Preview {
    @Previewable @State var textProperty: TextProperty? = nil

    TextTabView(selectedTextProperty: $textProperty)
        .environmentObject(TextProperties())
        .environmentObject(ObservablePaperEAN())
}
