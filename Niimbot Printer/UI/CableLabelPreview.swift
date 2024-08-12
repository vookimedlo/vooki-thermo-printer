//
//  CableLabelPreview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.08.2024.
//

import SwiftUI

struct CableLabelPreview: View {
    @Environment(ImagePreview.self) private var imagePreview
    @Environment(ObservablePaperEAN.self) private var paperEAN
    
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
        @Bindable var paperEAN = paperEAN
        
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        let cornerRadius = paperEAN.ean.cornerRadius
                        let printableCornerRadius = paperEAN.ean.printableSizeInPixels == paperEAN.ean.physicalSizeInPixels ? cornerRadius : 0
                        HStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(paperColor)
                                    .shadow(color: .accentColor, radius: cornerRadius)
                                    .frame(width: $paperEAN.wrappedValue.ean.printableSizeInPixels.width,
                                           height: $paperEAN.wrappedValue.ean.physicalSizeInPixels.height)
                                
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
                            
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 10, topTrailing: 10), style: .continuous)
                                .fill(paperColor)
                                .shadow(color: .accentColor,
                                        radius: cornerRadius,
                                        x: cornerRadius + 2)
                                .frame(width: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width - $paperEAN.wrappedValue.ean.printableSizeInPixels.width,
                                       height: 56)
                            
                            
                        }
                    }
                    Spacer()
                }
                
                leadingVerticalDescription(color: printableColor,
                                           paperWidth: $paperEAN.wrappedValue.ean.printableSizeInPixels.width,
                                           physicalPaperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width,
                                           paperHeight: $paperEAN.wrappedValue.ean.printableSizeInPixels.height,
                                           description: "\($paperEAN.wrappedValue.ean.printableSizeInMillimeters.height)",
                                           offset: 5)
                .help("The height of printable area.")
                
                leadingVerticalDescription(color: physicalColor,
                                           paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width,
                                           physicalPaperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width,
                                           paperHeight: $paperEAN.wrappedValue.ean.physicalSizeInPixels.height,
                                           description: "\($paperEAN.wrappedValue.ean.physicalSizeInMillimeters.height)",
                                           offset: 25)
                .help("The height of paper.")
                
                trailingVerticalDescription(color: physicalColor,
                                            paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width,
                                            paperHeight: 56,
                                            description: "8",
                                            offset: 25)
                .help("The height of paper.")
            }
            
            leadingHorizontalDescription(color: printableColor,
                                         paperWidth: $paperEAN.wrappedValue.ean.printableSizeInPixels.width,
                                         physicalPaperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width,
                                         description: "\($paperEAN.wrappedValue.ean.printableSizeInMillimeters.width)")
            .help("The width of printable area.")
            
            centerHorizontalDescription(color: physicalColor,
                                        paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels.width,
                                        description: "\($paperEAN.wrappedValue.ean.physicalSizeInMillimeters.width)")
            .help("The width of paper.")
        }
    }
    
    @ViewBuilder
    private func marginGuide() -> some View {
        LabelPreview.marginGuide(paperEAN: paperEAN.ean,
                                 horizontalMargin: horizontalMargin,
                                 verticalMargin: verticalMargin,
                                 marginColor: marginColor,
                                 marginThickness: marginThickness)
    }
    
    @ViewBuilder
    private func leadingHorizontalDescription(color: Color, paperWidth: Double, physicalPaperWidth: Double, description: String) -> some View {
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
    private func centerHorizontalDescription(color: Color, paperWidth: Double, description: String) -> some View {
        LabelPreview.centerHorizontalDescription(color: color,
                                                 paperWidth: paperWidth,
                                                 description: description,
                                                 descriptionLength: descriptionLength,
                                                 descriptionThickness: descriptionThickness)
    }
    
    @ViewBuilder
    private func leadingVerticalDescription(color: Color, paperWidth: Double, physicalPaperWidth: Double, paperHeight: Double, description: String, offset: Double) -> some View {
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
    private func trailingVerticalDescription(color: Color, paperWidth: Double, paperHeight: Double, description: String, offset: Double) -> some View {
        LabelPreview.trailingVerticalDescription(color: color,
                                                 paperWidth: paperWidth,
                                                 paperHeight: paperHeight,
                                                 description: description,
                                                 offset: offset,
                                                 descriptionLength: descriptionLength,
                                                 descriptionThickness: descriptionThickness)
    }
}

#Preview {
    @Previewable @State var horizontalMargin: any HorizontalMarginable = Margin.none
    @Previewable @State var verticalMargin: any VerticalMarginable = Margin.none
    
    CableLabelPreview(horizontalMargin: $horizontalMargin, verticalMargin: $verticalMargin)
        .environmentObject(ImagePreview())
        .environmentObject({ () -> ObservablePaperEAN in
            let ean = ObservablePaperEAN()
            ean.ean = .ean6972842743787
            return ean
        }())
}
