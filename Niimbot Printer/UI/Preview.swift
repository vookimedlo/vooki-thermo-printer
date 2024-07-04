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
    
    private let controlColor = Color(NSColor.disabledControlTextColor)
    var i = NSImage(size: NSSize(width: 240, height: 80))

    private let descriptionLength = 15.0
    private let descriptionThickness = 3.0

    var body: some View {
        @Bindable var imagePreview = imagePreview
        @Bindable var paperType = paperType

        VStack(spacing: 0) {
            ZStack {
                HStack{
                    Spacer()
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .shadow(color: .accentColor, radius: 30)
                            .frame(width: $paperType.wrappedValue.type.physicalSizeInPixels.width,
                                   height: $paperType.wrappedValue.type.physicalSizeInPixels.height)
                        Image(nsImage: imagePreview.image).border(.red, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    }
                    Spacer()
                }
                
                verticalDescription(color: .red,
                    paperWidth: $paperType.wrappedValue.type.printableSizeInPixels.width,
                    paperHeight: $paperType.wrappedValue.type.printableSizeInPixels.height,
                                    description: "\($paperType.wrappedValue.type.printableSizeInMillimeters.height)",
                                    offset: 40)
                .help("The height of printable area.")
                
                verticalDescription(color: .green,
                    paperWidth: $paperType.wrappedValue.type.physicalSizeInPixels.width,
                    paperHeight: $paperType.wrappedValue.type.physicalSizeInPixels.height,
                    description: "\($paperType.wrappedValue.type.physicalSizeInMillimeters.height)",
                    offset: 95)
                .help("The height of paper.")
            }
            
            horizontalDescription(color: .red,
                paperWidth: $paperType.wrappedValue.type.printableSizeInPixels.width,
                description: "\($paperType.wrappedValue.type.printableSizeInMillimeters.width)")
            .help("The width of printable area.")

            horizontalDescription(color: .green,
                paperWidth: $paperType.wrappedValue.type.physicalSizeInPixels.width,
                description: "\($paperType.wrappedValue.type.physicalSizeInMillimeters.width)")
            .help("The width of paper.")
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
    Preview()
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperType())
}
