//
//  SegmentedPickerView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 29.06.2024.
//

import SwiftUI

protocol SegmentedPrickerHelp {
    var help: String { get }
}

struct SegmentedPickerView<Data, Content>: View where Data: Hashable, Content: View {
    @Binding private var selection: Data
    
    private let controlBackgroundColor = Color(NSColor.separatorColor)
    //private let controlBackgroundColor = Color(NSColor.disabledControlTextColor).opacity(0.25)
    private let controlSelectedColor = Color(NSColor.selectedControlColor)
    
    private let cornerRadius = 5.0
    private let height = 25.0
    
    private let data: [Data]
    private let itemBuilder: (Data) -> Content

    public init(_ data: [Data], selection: Binding<Data>, @ViewBuilder itemBuilder: @escaping (Data) -> Content) {
        self.data = data
        self._selection = selection
        self.itemBuilder = itemBuilder
        
    }
        
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ForEach(0..<data.count, id: \.self) { i in
                    HStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(data[i] == selection ? controlSelectedColor : controlBackgroundColor)
                            .frame(width: geo.size.width / CGFloat(data.count))
                            .overlay {
                                itemBuilder(data[i])
                            }
                    }
                    .help(data[i] is SegmentedPrickerHelp ? (data[i] as! SegmentedPrickerHelp).help : "")
                    .gesture(TapGesture()
                        .onEnded({gesture in
                            withAnimation(.snappy) {
                                selection = data[i]
                            }
                        }))
                    .offset(x: (geo.size.width / CGFloat(data.count)) * Double(i))
                }
            }
        }.frame(height: height)
    }
}

//#Preview {
//    SegmentedPickerView()
//}
