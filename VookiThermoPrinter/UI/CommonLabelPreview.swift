//
//  CommonLabelPreview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.08.2024.
//

import SwiftUI

@MainActor
struct CommonLabelPreview {
    static let controlColor = Color(NSColor.disabledControlTextColor)
    
    static let descriptionLength = 15.0
    static let descriptionThickness = 3.0
    
    static let marginThickness = 2.0
    
    static let marginColor = Color.blue
    static let paperColor = Color.white
    static let physicalColor = Color.green
    static let printableColor = Color.red
    
    @ViewBuilder
    static func centerHorizontalDescription(color: Color, paperWidth: Double, description: String, descriptionLength: Double, descriptionThickness: Double) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0){
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionThickness,
                           height: descriptionLength)
                    .padding(.trailing, paperWidth - descriptionThickness * 2)
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionThickness,
                           height: descriptionLength)
            }
            Rectangle()
                .fill(color)
                .frame(width: paperWidth, height: descriptionThickness)
            Text("\(description) mm")
        }
    }
    
    @ViewBuilder
    static func leadingHorizontalDescription(color: Color, paperWidth: Double, physicalPaperWidth: Double, description: String, descriptionLength: Double, descriptionThickness: Double) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0){
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionThickness,
                           height: descriptionLength)
                    .padding(.trailing, paperWidth - descriptionThickness * 2)
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionThickness,
                           height: descriptionLength)
                    .padding(.trailing, physicalPaperWidth - paperWidth)
                
            }
            Rectangle()
                .fill(color)
                .frame(width: paperWidth, height: descriptionThickness)
                .padding(.trailing, physicalPaperWidth - paperWidth)
            Text("\(description) mm")
                .padding(.trailing, physicalPaperWidth - paperWidth)
        }
    }
    
    @ViewBuilder
    static func leadingVerticalDescription(color: Color, paperWidth: Double, physicalPaperWidth: Double, paperHeight: Double, description: String, offset: Double, descriptionLength: Double, descriptionThickness: Double) -> some View {
        ZStack {
            let leadingPadding = -(physicalPaperWidth/2 + descriptionLength + offset)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionLength,
                           height: descriptionThickness)
                    .padding(.bottom, paperHeight - descriptionThickness * 2)
                    .padding(.leading, leadingPadding)
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionLength,
                           height: descriptionThickness)
                    .padding(.leading, leadingPadding)
            }
            Rectangle()
                .fill(color)
                .frame(width: descriptionThickness,
                       height: paperHeight)
                .padding(.leading, leadingPadding)
            Text("\(description) mm").rotationEffect(.degrees(-90))
                .padding(.leading, leadingPadding - 35)
        }
    }
    
    @ViewBuilder
    static func trailingVerticalDescription(color: Color, paperWidth: Double, paperHeight: Double, description: String, offset: Double, descriptionLength: Double, descriptionThickness: Double) -> some View {
        ZStack {
            VStack(spacing: 0) {
                let leadinOffset = paperWidth - descriptionLength + descriptionThickness + offset
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionLength,
                           height: descriptionThickness)
                    .padding(.bottom, paperHeight - descriptionThickness * 2)
                    .padding(.leading, leadinOffset)
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionLength,
                           height: descriptionThickness)
                    .padding(.leading, leadinOffset)
            }
            let leadingOffset = paperWidth + offset
            Rectangle()
                .fill(color)
                .frame(width: descriptionThickness,
                       height: paperHeight)
                .padding(.leading, leadingOffset)
            Text("\(description) mm").rotationEffect(.degrees(-90))
                .padding(.leading, leadingOffset + 20)
        }
    }
    
    @ViewBuilder
    static func marginGuide(paperEAN: PaperEAN, horizontalMargin: any HorizontalMarginable, verticalMargin: any VerticalMarginable, marginColor: Color, marginThickness: Double) -> some View {
        ZStack{
            HStack {
                if (!horizontalMargin.isNone) {
                    let paperHeight = paperEAN.printableSizeInPixels.height
                    
                    if (horizontalMargin.edge!.contains(.trailing)) {
                        Spacer()
                    }
                    Rectangle()
                        .fill(marginColor)
                        .frame(width: marginThickness,
                               height: paperHeight)
                        .padding(horizontalMargin.edge!,
                                 horizontalMargin.fsize)
                    if (horizontalMargin.edge!.contains(.leading)) {
                        Spacer()
                    }
                }
            }
            
            VStack {
                if (!verticalMargin.isNone) {
                    let paperWidth = paperEAN.printableSizeInPixels.width
                    
                    if (verticalMargin.edge!.contains(.bottom)) {
                        Spacer()
                    }
                    Rectangle()
                        .fill(marginColor)
                        .frame(width: paperWidth,
                               height: marginThickness)
                        .padding(verticalMargin.edge!,
                                 verticalMargin.fsize)
                    if (verticalMargin.edge!.contains(.top)) {
                        Spacer()
                    }
                }
            }
        }
    }
}
