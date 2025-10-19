//
//  LabelPreview.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 04.07.2024.
//

import SwiftUI

struct LabelPreview: View {
    @Environment(ImagePreview.self) private var imagePreview
    @Environment(ObservablePaperEAN.self) private var paperEAN
    @Environment(\.appDetails) var appDetails
    
    @Binding var horizontalMargin: any HorizontalMarginable
    @Binding var verticalMargin: any VerticalMarginable
    
    var body: some View {
        @Bindable var imagePreview = imagePreview
        @Bindable var paperEAN = paperEAN
        
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        let cornerRadius = paperEAN.ean.cornerRadius
                        let printableCornerRadius = paperEAN.ean.printableSizeInPixels(dpi: appDetails.dpi) == paperEAN.ean.physicalSizeInPixels(dpi: appDetails.dpi) ? cornerRadius : 0
                        
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(CommonLabelPreview.paperColor)
                            .shadow(color: .accentColor, radius: cornerRadius)
                            .frame(width: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: appDetails.dpi).width,
                                   height: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: appDetails.dpi).height)
                        if (imagePreview.image != nil) {
                            let size = NSSize(width: imagePreview.image!.width,
                                              height: imagePreview.image!.height)
                            Image(nsImage: NSImage(cgImage: imagePreview.image!,
                                                   size: size))
                            .cornerRadius(printableCornerRadius)
                            .border(CommonLabelPreview.printableColor, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                            .overlay {
                                marginGuide()
                            }
                        }
                    }
                    Spacer()
                }
                
                trailingVerticalDescription(color: CommonLabelPreview.printableColor,
                                            paperWidth: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: appDetails.dpi).width,
                                            paperHeight: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: appDetails.dpi).height,
                                            description: "\($paperEAN.wrappedValue.ean.printableSizeInMillimeters.height)",
                                            offset: 40)
                .help("The height of printable area.")
                
                trailingVerticalDescription(color: CommonLabelPreview.physicalColor,
                                            paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: appDetails.dpi).width,
                                            paperHeight: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: appDetails.dpi).height,
                                            description: "\($paperEAN.wrappedValue.ean.physicalSizeInMillimeters.height)",
                                            offset: 95)
                .help("The height of paper.")
            }
            
            centerHorizontalDescription(color: CommonLabelPreview.printableColor,
                                        paperWidth: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: appDetails.dpi).width,
                                        description: "\($paperEAN.wrappedValue.ean.printableSizeInMillimeters.width)")
            .help("The width of printable area.")
            
            centerHorizontalDescription(color: CommonLabelPreview.physicalColor,
                                        paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: appDetails.dpi).width,
                                        description: "\($paperEAN.wrappedValue.ean.physicalSizeInMillimeters.width)")
            .help("The width of paper.")
        }
    }
    
    @ViewBuilder
    private func marginGuide() -> some View {
        CommonLabelPreview.marginGuide(paperEAN: paperEAN.ean,
                                       horizontalMargin: horizontalMargin,
                                       verticalMargin: verticalMargin,
                                       marginColor: CommonLabelPreview.marginColor,
                                       marginThickness: CommonLabelPreview.marginThickness,
                                       dpi: appDetails.dpi)
    }
    
    @ViewBuilder
    private func centerHorizontalDescription(color: Color, paperWidth: Double, description: String) -> some View {
        CommonLabelPreview.centerHorizontalDescription(color: color,
                                                       paperWidth: paperWidth,
                                                       description: description,
                                                       descriptionLength: CommonLabelPreview.descriptionLength,
                                                       descriptionThickness: CommonLabelPreview.descriptionThickness)
    }

    @ViewBuilder
    private func trailingVerticalDescription(color: Color, paperWidth: Double, paperHeight: Double, description: String, offset: Double) -> some View {
        CommonLabelPreview.trailingVerticalDescription(color: color,
                                                       paperWidth: paperWidth,
                                                       paperHeight: paperHeight,
                                                       description: description,
                                                       offset: offset,
                                                       descriptionLength: CommonLabelPreview.descriptionLength,
                                                       descriptionThickness: CommonLabelPreview.descriptionThickness)
    }
}

#Preview {
    @Previewable @State var horizontalMargin: any HorizontalMarginable = Margin.none
    @Previewable @State var verticalMargin: any VerticalMarginable = Margin.none
    
    LabelPreview(horizontalMargin: $horizontalMargin, verticalMargin: $verticalMargin)
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperEAN())
}

