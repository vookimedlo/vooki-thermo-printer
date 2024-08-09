//
//  Preview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import SwiftUI

struct Preview: View {
    @Environment(ImagePreview.self) private var imagePreview
    @Environment(ObservablePaperType.self) private var paperType
    
    @Binding var horizontalMargin: any HorizontalMarginable
    @Binding var verticalMargin: any VerticalMarginable


    private let controlColor = Color(NSColor.disabledControlTextColor)

    private let descriptionLength = 15.0
    private let descriptionThickness = 3.0

    private let marginThickness = 2.0

    private let marginColor = Color.blue
    private let paperColor = Color.white
    private let physicalColor = Color.green
    private let printableColor = Color.red


    var body: some View {
        @Bindable var imagePreview = imagePreview
        @Bindable var paperType = paperType

        VStack(spacing: 0) {
            ZStack {
                HStack{
                    Spacer()
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        let cornerRadius = paperType.type.cornerRadius
                        let printableCornerRadius = paperType.type.printableSizeInPixels == paperType.type.physicalSizeInPixels ? cornerRadius : 0

                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(paperColor)
                            .shadow(color: .accentColor, radius: cornerRadius)
                            .frame(width: $paperType.wrappedValue.type.physicalSizeInPixels.width,
                                   height: $paperType.wrappedValue.type.physicalSizeInPixels.height)
                        if (imagePreview.image != nil) {
                            let size = NSSize(width: imagePreview.image!.width,
                                              height: imagePreview.image!.height)
                            Image(nsImage: NSImage(cgImage: imagePreview.image!,
                                                   size: size))
                            .cornerRadius(printableCornerRadius)
                            .border(printableColor, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                            .overlay {
                                marginGuide()
                            }
                        }
                    }
                    Spacer()
                }
                
                verticalDescription(color: printableColor,
                    paperWidth: $paperType.wrappedValue.type.printableSizeInPixels.width,
                    paperHeight: $paperType.wrappedValue.type.printableSizeInPixels.height,
                                    description: "\($paperType.wrappedValue.type.printableSizeInMillimeters.height)",
                                    offset: 40)
                .help("The height of printable area.")
                
                verticalDescription(color: physicalColor,
                    paperWidth: $paperType.wrappedValue.type.physicalSizeInPixels.width,
                    paperHeight: $paperType.wrappedValue.type.physicalSizeInPixels.height,
                    description: "\($paperType.wrappedValue.type.physicalSizeInMillimeters.height)",
                    offset: 95)
                .help("The height of paper.")
            }
            
            horizontalDescription(color: printableColor,
                paperWidth: $paperType.wrappedValue.type.printableSizeInPixels.width,
                description: "\($paperType.wrappedValue.type.printableSizeInMillimeters.width)")
            .help("The width of printable area.")

            horizontalDescription(color: physicalColor,
                paperWidth: $paperType.wrappedValue.type.physicalSizeInPixels.width,
                description: "\($paperType.wrappedValue.type.physicalSizeInMillimeters.width)")
            .help("The width of paper.")
        }
    }
    
    @ViewBuilder
    private func marginGuide() -> some View {
        @Bindable var paperType = paperType

        ZStack{
            HStack {
                if (!horizontalMargin.isNone) {
                    let paperHeight = $paperType.wrappedValue.type.printableSizeInPixels.height
                    
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
                    let paperWidth = $paperType.wrappedValue.type.printableSizeInPixels.width
                    
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
    
    @ViewBuilder
    private func horizontalDescription(color: Color, paperWidth: Double, description: String) -> some View {
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
    private func verticalDescription(color: Color, paperWidth: Double, paperHeight: Double, description: String, offset: Double) -> some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionLength,
                           height: descriptionThickness)
                    .padding(.bottom, paperHeight - descriptionThickness * 2)
                    .padding(.leading, paperWidth - descriptionLength + descriptionThickness + offset)
                Rectangle()
                    .fill(color)
                    .frame(width: descriptionLength,
                           height: descriptionThickness)
                    .padding(.leading, paperWidth - descriptionLength + descriptionThickness + offset)
            }
            Rectangle()
                .fill(color)
                .frame(width: descriptionThickness,
                       height: paperHeight)
                .padding(.leading, paperWidth + offset)
            Text("\(description) mm").rotationEffect(.degrees(-90))
                .padding(.leading, paperWidth + 20 + offset)
        }
    }
}

#Preview {
    @Previewable @State var horizontalMargin: any HorizontalMarginable = Margin.none
    @Previewable @State var verticalMargin: any VerticalMarginable = Margin.none

    Preview(horizontalMargin: $horizontalMargin, verticalMargin: $verticalMargin)
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperType())
}
