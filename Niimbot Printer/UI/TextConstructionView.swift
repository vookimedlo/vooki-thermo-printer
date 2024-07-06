//
//  TextConstructionView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.07.2024.
//

import SwiftUI


struct TextConstructionView: View {    
    @Environment(TextProperty.self) private var textProperty

    var body: some View {
        @Bindable var textProperty = textProperty
        
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
                    
                    HStack {
                        Spacer()
                        TextField("Enter your text for printing ...", text: $textProperty.text)
                        Spacer()
                    }
                }.padding()
            } label: {
                Text("What to print")
            }
            
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
                    
                    FontSelectionView(fontSelection: $textProperty.fontDetails.name,
                                      familySelection: $textProperty.fontDetails.family,
                                      fontSize: $textProperty.fontDetails.size)
                    .padding()
                } label: {
                    Text("Text properties")
                }
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
                    
                    
                    IndicatorValueSlider(value: $textProperty.squareCodeSize,
                                        minValue: 75,
                                        maxValue: 120,
                                        label: { Text("Size").font(.headline) }).padding(.horizontal)

                    
                } label: {
                    Text("QR code properties")
                }
            }
        }
    }
}

#Preview {
    TextConstructionView()
        .environmentObject(TextProperty())
}
