//
//  TextConstructionView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.07.2024.
//

import SwiftUI
import TipKit
import UniformTypeIdentifiers


struct TextConstructionView: View {
    @Environment(TextProperty.self) private var textProperty
    @Environment(ObservablePaperEAN.self) private var paperEAN
    
   // @State private var selectedDecoration: Decoration = .custom

    var body: some View {
        @Bindable var textProperty = textProperty
        @Bindable var paperEAN = paperEAN

        VStack() {
            GroupBox {
                VStack{
                    HStack {
                        Spacer()
                        SegmentedPickerView(TextProperty.WhatToPrint.allCases, selection: $textProperty.whatToPrint) { item in
                            Text(item.help)
                        }.frame(width: 200)
                        Spacer().frame(maxWidth: .infinity)
                    }.padding(.bottom)
                    
                    switch textProperty.whatToPrint {
                    case .image:
                        
                        Form {
                            Picker("Decoration", selection: $textProperty.imageDecoration) {
                                ForEach(Decoration.allCases, id: \.self) {item in
                                    Text(item.name)
                                }
                            }
                        }
                        
                        if (textProperty.imageDecoration == .custom) {
                            TipView(ImageTip(size: paperEAN.ean.printableSizeInPixels),
                                    arrowEdge: .bottom)
                            .containerRelativeFrame(.vertical, alignment: .top) { value, axis in
                                switch axis {
                                case .horizontal:
                                    return value
                                case .vertical:
                                    return 90
                                }
                            }
                        }
                            HStack {
                                ZStack {
                                    Rectangle().frame(width: paperEAN.ean.printableSizeInPixels.width, height: paperEAN.ean.printableSizeInPixels.height, alignment: .center)
                                        .foregroundStyle(.white)
                                        .shadow(color: .green, radius: 5)
                                    
                                    Image(nsImage: textProperty.image.count > 0 ? NSImage(data: textProperty.image)! : NSImage(size: paperEAN.ean.printableSizeInPixels))
                                        .frame(width: paperEAN.ean.printableSizeInPixels.width, height: paperEAN.ean.printableSizeInPixels.height, alignment: .center)
                                }
                                .dropDestination(for: NSImage.self) { items, _ in
                                    guard let image = items.first else { return false }
                                    guard items.count == 1 else { return false }
                                    
                                    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
                                    
                                    guard cgImage.width == Int(paperEAN.ean.printableSizeInPixels.width) && cgImage.height == Int(paperEAN.ean.printableSizeInPixels.height) else { return false }
    
                                    textProperty.image = cgImage.data

                                    return true
                                }
                            }
                    default:
                        HStack {
                            Spacer()
                            TextField("Enter your text for printing ...", text: $textProperty.text)
                            Spacer()
                        }
                    }
                }.padding()
            } label: {
                Text("What to print")
            }.padding(.bottom, textProperty.whatToPrint == .image ? 10 : 0)
            
            if textProperty.whatToPrint == .text {
                GroupBox {
                    GroupBox {
                        HStack{
                            AlignmentView(horizontalAlignment: $textProperty.horizontalAlignment.alignment,
                                          verticalAlignment: $textProperty.verticalAlignment.alignment)
                            Spacer().frame(maxWidth: .infinity)
                        }
                    } label: {
                        Text("Alignment")
                    }.padding(.horizontal)
                    
                    marginView().padding(.top)
                    
                    FontSelectionView(fontSelection: $textProperty.fontDetails.name,
                                      familySelection: $textProperty.fontDetails.family,
                                      fontSize: $textProperty.fontDetails.size)
                    .padding()
                } label: {
                    Text("Text properties")
                }
                .padding(.bottom)
            }
            
            if textProperty.whatToPrint == .qr {
                GroupBox {
                    GroupBox {
                        HStack{
                            AlignmentView(horizontalAlignment: $textProperty.horizontalAlignment.alignment,
                                          verticalAlignment: $textProperty.verticalAlignment.alignment)
                            Spacer().frame(maxWidth: .infinity)
                        }
                    } label: {
                        Text("Alignment")
                    }.padding(.horizontal)
                    
                    marginView().padding(.vertical)
                    
                    HStack {
                        Form {
                            IndicatorValueSlider(value: $textProperty.squareCodeSize,
                                                 minValue: 75,
                                                 maxValue: 120,
                                                 label: { Text("Size").font(.headline) }).padding(.horizontal, 20)
                        }
                    }
                } label: {
                    Text("QR code properties")
                }
                .padding(.bottom)
            }
        }
    }
    
    private struct ImageTip: Tip {
        let size: CGSize
        
        init (size: CGSize) {
            self.size = size
        }
        
        var title: Text {
            Text("Drag your image here")
        }

        var message: Text? {
            Text("Your image has to be a \(Int(size.width))x\(Int(size.height)) pixel sized with transparent background.")
        }

        var image: Image? {
            Image(systemName: "exclamationmark.square").symbolRenderingMode(.multicolor)
        }
    }
    
    @ViewBuilder
    private func marginView() -> some View {
        @Bindable var textProperty = textProperty

        if $textProperty.horizontalAlignment.alignment.wrappedValue != .center || $textProperty.verticalAlignment.alignment.wrappedValue != .center {
            GroupBox {
                HStack {
                    Form {
                        if $textProperty.horizontalAlignment.alignment.wrappedValue == .left {
                            IndicatorValueSlider(value: $textProperty.margin.leading,
                                                 minValue: -99,
                                                 maxValue: 99,
                                                 label: { Text("Leading").font(.headline) }).padding(.horizontal)
                        }
                        
                        if $textProperty.horizontalAlignment.alignment.wrappedValue == .right {
                            IndicatorValueSlider(value: $textProperty.margin.trailing,
                                                 minValue: -99,
                                                 maxValue: 99,
                                                 label: { Text("Trailing").font(.headline) }).padding(.horizontal)
                        }
                        
                        if $textProperty.verticalAlignment.alignment.wrappedValue == .top {
                            IndicatorValueSlider(value: $textProperty.margin.top,
                                                 minValue: -99,
                                                 maxValue: 99,
                                                 label: { Text("Top").font(.headline) }).padding(.horizontal)
                        }
                        
                        if $textProperty.verticalAlignment.alignment.wrappedValue == .bottom {
                            IndicatorValueSlider(value: $textProperty.margin.bottom,
                                                 minValue: -99,
                                                 maxValue: 99,
                                                 label: { Text("Bottom").font(.headline) }).padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            } label: {
                Text("Margins")
            }.padding(.horizontal)
        }
    }
}

#Preview {
    TextConstructionView()
        .environmentObject(TextProperty())
}
