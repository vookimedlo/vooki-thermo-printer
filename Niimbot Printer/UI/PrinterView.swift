//
//  PrinterView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI


struct PrinterView: View, Notifier {
    @Environment(HorizontalTextAlignment.self) private var horizontalAlignment
    @Environment(VerticalTextAlignment.self) private var verticalAlignment

    @Environment(FontDetails.self) private var fontDetails
    @Environment(TextDetails.self) private var textDetails
    
    @State private var showingInspector: Bool = true
    @State private var showingPrintingProgress: Bool = false
    
    var body: some View {
        @Bindable var horizontalAlignment = horizontalAlignment
        @Bindable var verticalAlignment = verticalAlignment
        
        @Bindable var fontDetails = fontDetails
        @Bindable var textDetails = textDetails
        VStack {
            GroupBox {
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        Preview()
                        Spacer()
                    }
                    Spacer()
                }
            } label: {
                Text("Paper preview")
            }.padding()
            
            Spacer()
            
            GroupBox {
                HStack {
                    Spacer()
                    TextField("Enter your text for printing ...", text: $textDetails.text).padding()
                    Spacer()
                }
            } label: {
                Text("What to print")
            }.padding()
            
            GroupBox {
                GroupBox {
                    HStack{
                        AlignmentView(horizontalAlignment: $horizontalAlignment.alignment,
                                      verticalAlignment: $verticalAlignment.alignment)
                        Spacer().frame(maxWidth: .infinity)
                    }
                } label: {
                    Text("Alignment")
                }.padding(.horizontal)
                
                FontSelectionView(fontSelection: $fontDetails.name,
                                  familySelection: $fontDetails.family,
                                  fontSize: $fontDetails.size).padding()
                
            } label: {
                Text("Text properties")
            }.padding(.horizontal)
            
            
            HStack {
                Button {
                    notify(name: Notification.Name.App.printRequested)
                } label: {
                    Text("Print").fontWeight(.heavy)
                        .frame(maxWidth: .infinity).padding()
                }
                .background(Color.accentColor, in: .buttonBorder)
            }.padding(.horizontal, 250).padding(.bottom)
        }.navigationTitle("D110 Printer")
            .inspector(isPresented: $showingInspector) {
                VStack {
                    List {
                        Section(header: Text("Printer")) {
                            PrinterDetailsView()
                        }
                        
                        Section(header: Text("Paper")) {
                            PrinterLabelDetailView()
                        }
                    }.listStyle(.sidebar)
                    Spacer()
                }
            }.onReceive(NotificationCenter.default.publisher(for: .App.UI.printStarted)) { _ in
                withAnimation {
                    showingPrintingProgress = true
                }
            }.onReceive(NotificationCenter.default.publisher(for: .App.UI.printDone)) { _ in
                withAnimation {
                    showingPrintingProgress = false
                }
            }
            .sheet(isPresented: $showingPrintingProgress) {
                VStack {
                    Text("Printing ...").padding(.top)
                    Divider()
                    HStack {
                        Spacer()
                        PrintingProgress()
                        Spacer()
                    }.padding()}
                .frame(minWidth: 600)
            }.toolbar {
                ToolbarItem() {
                    Button {
                        withAnimation {
                            showingInspector = !showingInspector
                        }
                    } label: {
                        SwiftUI.Image(systemName: "sidebar.right")
                    }
                }
            }
    }
}

#Preview {
    PrinterView()
}
