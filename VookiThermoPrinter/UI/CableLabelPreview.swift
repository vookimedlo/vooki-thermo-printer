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
    @Environment(\.dpi) private var dpi
    
    @Binding var horizontalMargin: any HorizontalMarginable
    @Binding var verticalMargin: any VerticalMarginable
    
    private static let tailPhysicalHeightInMM = 8.0
    private var tailPhysicalHeightInPixels: Double { PixelCalculator.pixels(lengthInMM: Self.tailPhysicalHeightInMM, dpi: Double(dpi.rawValue)) }
    
    var body: some View {
        @Bindable var imagePreview = imagePreview
        @Bindable var paperEAN = paperEAN
        
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        let cornerRadius = paperEAN.ean.cornerRadius
                        let printableCornerRadius = paperEAN.ean.printableSizeInPixels(dpi: dpi) == paperEAN.ean.physicalSizeInPixels(dpi: dpi) ? cornerRadius : 0
                        HStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(CommonLabelPreview.paperColor)
                                    .shadow(color: .accentColor, radius: cornerRadius)
                                    .frame(width: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: dpi).width,
                                           height: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).height)
                                
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

                                VerticalLine()
                                    .stroke(style: .init(lineWidth: 2, dash: [12]))
                                    .foregroundStyle(.orange)
                                    .padding(.leading, paperEAN.ean.printableSizeInPixels(dpi: dpi).width / 2)
                                    .frame(width: paperEAN.ean.printableSizeInPixels(dpi: dpi).width,
                                           height: paperEAN.ean.physicalSizeInPixels(dpi: dpi).height)
                            }
                            
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 10, topTrailing: 10), style: .continuous)
                                .fill(CommonLabelPreview.paperColor)
                                .shadow(color: .accentColor,
                                        radius: cornerRadius,
                                        x: cornerRadius + 2)
                                .frame(width: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width - $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: dpi).width,
                                       height: tailPhysicalHeightInPixels)
                        }
                    }
                    Spacer()
                }

                leadingVerticalDescription(color: CommonLabelPreview.printableColor,
                                           paperWidth: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: dpi).width,
                                           physicalPaperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width,
                                           paperHeight: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: dpi).height,
                                           description: "\($paperEAN.wrappedValue.ean.printableSizeInMillimeters.height)",
                                           offset: 5)
                .help("The height of printable area.")
                
                leadingVerticalDescription(color: CommonLabelPreview.physicalColor,
                                           paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width,
                                           physicalPaperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width,
                                           paperHeight: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).height,
                                           description: "\($paperEAN.wrappedValue.ean.physicalSizeInMillimeters.height)",
                                           offset: 25)
                .help("The height of paper.")
                
                trailingVerticalDescription(color: CommonLabelPreview.physicalColor,
                                            paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width,
                                            paperHeight: tailPhysicalHeightInPixels,
                                            description: "\(Self.tailPhysicalHeightInMM)",
                                            offset: 25)
                .help("The height of paper.")
            }
            
            leadingHorizontalDescription(color: CommonLabelPreview.printableColor,
                                         paperWidth: $paperEAN.wrappedValue.ean.printableSizeInPixels(dpi: dpi).width,
                                         physicalPaperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width,
                                         description: "\($paperEAN.wrappedValue.ean.printableSizeInMillimeters.width)")
            .help("The width of printable area.")
            
            centerHorizontalDescription(color: CommonLabelPreview.physicalColor,
                                        paperWidth: $paperEAN.wrappedValue.ean.physicalSizeInPixels(dpi: dpi).width,
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
                                       dpi: dpi)
    }
    
    @ViewBuilder
    private func leadingHorizontalDescription(color: Color, paperWidth: Double, physicalPaperWidth: Double, description: String) -> some View {
        CommonLabelPreview.leadingHorizontalDescription(color: color,
                                                        paperWidth: paperWidth,
                                                        physicalPaperWidth: physicalPaperWidth,
                                                        description: description,
                                                        descriptionLength: CommonLabelPreview.descriptionLength,
                                                        descriptionThickness: CommonLabelPreview.descriptionThickness)
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
    private func leadingVerticalDescription(color: Color, paperWidth: Double, physicalPaperWidth: Double, paperHeight: Double, description: String, offset: Double) -> some View {
        CommonLabelPreview.leadingVerticalDescription(color: color,
                                                      paperWidth: paperWidth,
                                                      physicalPaperWidth: physicalPaperWidth,
                                                      paperHeight: paperHeight,
                                                      description: description,
                                                      offset: offset,
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
    
    CableLabelPreview(horizontalMargin: $horizontalMargin, verticalMargin: $verticalMargin)
        .environmentObject(ImagePreview())
        .environmentObject({ () -> ObservablePaperEAN in
            let ean = ObservablePaperEAN()
            ean.ean = .ean6972842743787
            return ean
        }())
}
