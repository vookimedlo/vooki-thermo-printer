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
                HStack {
                    Spacer()
                    TextField("Enter your text for printing ...", text: $textProperty.text)
                        .padding()
                    Spacer()
                }
            } label: {
                Text("What to print")
            }
            
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
    }
}

#Preview {
    TextConstructionView()
        .environmentObject(TextProperty())
}
