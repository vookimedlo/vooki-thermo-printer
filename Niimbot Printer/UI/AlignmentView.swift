//
//  AlignmentView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 29.06.2024.
//

import SwiftUI

struct AlignmentView: View {
    public enum HorizontalAlignment: Int, CaseIterable, SegmentedPrickerHelp {
        case left, center, right
        
        var help: String {
            switch self {
            case .left: return "Left"
            case .center: return "Center"
            case .right: return "Right"
            }
        }
        var symbol: Image {
            switch self {
            case .left: return Image(systemName: "text.alignleft")
            case .center: return Image(systemName: "text.aligncenter")
            case .right: return Image(systemName: "text.alignright")
            }
        }
    }

    public enum VerticalAlignment: Int, CaseIterable, SegmentedPrickerHelp {
        case bottom, center, top
        
        var help: String {
            switch self {
            case .bottom: return "Bottom"
            case .center: return "Center"
            case .top: return "Top"
            }
        }
        var symbol: Image {
            switch self {
            case .bottom: return Image(systemName: "text.alignleft")
            case .center: return Image(systemName: "text.aligncenter")
            case .top: return Image(systemName: "text.alignright")
            }
        }
    }
    
    @Binding private var horizontalAlignment: Self.HorizontalAlignment
    @Binding private var verticalAlignment: Self.VerticalAlignment
    
    init(horizontalAlignment: Binding<Self.HorizontalAlignment>, verticalAlignment: Binding<Self.VerticalAlignment>) {
        _horizontalAlignment = horizontalAlignment
        _verticalAlignment = verticalAlignment
    }

    var body: some View {
            VStack(alignment: .leading){
                HStack {
                    SegmentedPickerView(HorizontalAlignment.allCases, selection: $horizontalAlignment) { item in
                        item.symbol
                            .symbolRenderingMode(.monochrome)
                            .symbolVariant(.none)
                            .fontWeight(.regular)
                    }
                    
                    SegmentedPickerView(VerticalAlignment.allCases, selection: $verticalAlignment) { item in
                        item.symbol.rotationEffect(.degrees(-90))
                            .symbolRenderingMode(.monochrome)
                            .symbolVariant(.none)
                            .fontWeight(.regular)
                    }
                }
            }
        }
    }

//#Preview {
//    AlignmentView()
//}
