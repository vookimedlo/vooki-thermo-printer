//
//  PrinterView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI


struct PrinterView: View, Notifiable {
    @Environment(PrinterAvailability.self) private var printerAvailability
    @Environment(PrinterDetails.self) private var printerDetails
    @Environment(UISettingsProperties.self) private var uiSettingsProperties
    @Environment(ObservablePaperEAN.self) private var paperEAN


    @State private var showingInspector: Bool = true
    @State private var showingPrintingProgress: Bool = false
    
    @State private var selectedTextProperty: TextProperty?
    @State var horizontalMargin: any HorizontalMarginable = Margin.none
    @State var verticalMargin: any VerticalMarginable = Margin.none
    
    private let controlDisabledColor = Color(NSColor.disabledControlTextColor)

    var body: some View {
        VStack {
            GroupBox {
                ZStack {
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack(alignment: .center) {
                            GroupBox(label: Text("Type")) {
                                VStack(alignment: .leading) {
                                    Text(paperEAN.ean.description)
                                }
                            }.padding(10)
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                        HStack{
                            Spacer()
                            if paperEAN.ean.isCable == false {
                                LabelPreview(horizontalMargin: $horizontalMargin,
                                        verticalMargin: $verticalMargin)
                            }
                            else {
                                CableLabelPreview(horizontalMargin: $horizontalMargin,
                                        verticalMargin: $verticalMargin)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            GroupBox(label: Text("Legend")) {
                                VStack(alignment: .leading) {
                                    Text("Printable area").foregroundStyle(CommonLabelPreview.printableColor)
                                    Text("Physical area").foregroundStyle(CommonLabelPreview.physicalColor)
                                    if (paperEAN.ean.isCable) {
                                        Text("Folding divider").foregroundStyle(.orange)
                                    }
                                }
                            }.padding(10)
                        }
                    }
                }
            } label: {
                Text("Paper preview")
            }
            .padding()
            
            Spacer()
            
            TextTabView(selectedTextProperty: $selectedTextProperty).padding([.horizontal, .bottom])
                .onChange(of: selectedTextProperty?.margin.leading) {
                    computeHorizontalMargin()
                }
                .onChange(of: selectedTextProperty?.margin.trailing) {
                    computeHorizontalMargin()
                }
                .onChange(of: selectedTextProperty?.margin.bottom) {
                    computeVerticalMargin()
                }
                .onChange(of: selectedTextProperty?.margin.top) {
                    computeVerticalMargin()
                }
                .onChange(of: selectedTextProperty?.horizontalAlignment.alignment) {
                    computeHorizontalMargin()
                }
                .onChange(of: selectedTextProperty?.verticalAlignment.alignment) {
                    computeVerticalMargin()
                }
                .onChange(of: uiSettingsProperties.showHorizontalMarginGuideline) {
                    computeHorizontalMargin()
                }
                .onChange(of: uiSettingsProperties.showVerticalMarginGuideline) {
                    computeVerticalMargin()
                }
            HStack {
                Button {
                    notifyUI(name: Notification.Name.App.printRequested)
                } label: {
                    Text("Print").fontWeight(.heavy)
                        .frame(minWidth: 200, maxWidth: .infinity).padding()
                }
                .background(printerAvailability.isConnected ? Color.accentColor : controlDisabledColor, in: .buttonBorder)
                .disabled(!printerAvailability.isConnected)
            }
            .padding(.horizontal, 250).padding(.bottom)
        }
        .navigationTitle("D110 Printer")
            .inspector(isPresented: $showingInspector) {
                VStack {
                    List {
                        Section(header: Text("Printer")) {
                            PrinterDetailsView()
                        }
                        if printerAvailability.isConnected && printerDetails.isPaperInserted {
                            Section(header: Text("Paper")) {
                                PrinterLabelDetailView()
                            }
                        }
                    }
                    .listStyle(.sidebar)
                    Spacer()
                }
                .animation(.easeInOut, value: printerAvailability.isConnected)
                .animation(.easeInOut, value: printerDetails.isPaperInserted)
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
                .interactiveDismissDisabled()
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
    
    private func computeHorizontalMargin() {
        guard let selectedTextProperty = selectedTextProperty, uiSettingsProperties.showHorizontalMarginGuideline else {
            horizontalMargin = Margin.none
            return
        }
        switch selectedTextProperty.whatToPrint {
        case .text, .qr:
            switch selectedTextProperty.horizontalAlignment.alignment {
            case .left:
                let margin = selectedTextProperty.margin.leading
                horizontalMargin = margin >= 0 ? selectedTextProperty.margin.leadingMargin : Margin.none
            case .center:
                horizontalMargin = Margin.none
            case .right:
                let margin = selectedTextProperty.margin.trailing
                horizontalMargin = margin >= 0 ? selectedTextProperty.margin.trailingMargin : Margin.none
            }
        case .image:
            horizontalMargin = Margin.none
        }
    }
    
    private func computeVerticalMargin() {
        guard let selectedTextProperty = selectedTextProperty, uiSettingsProperties.showVerticalMarginGuideline else {
            verticalMargin = Margin.none
            return
        }
        switch selectedTextProperty.whatToPrint {
        case .text, .qr:
            switch selectedTextProperty.verticalAlignment.alignment {
            case .bottom:
                let margin = selectedTextProperty.margin.bottom
                verticalMargin = margin >= 0 ? selectedTextProperty.margin.bottomMargin : Margin.none
            case .center:
                verticalMargin = Margin.none
            case .top:
                let margin = selectedTextProperty.margin.top
                verticalMargin = margin >= 0 ? selectedTextProperty.margin.topMargin : Margin.none
            }
        case .image:
            verticalMargin = Margin.none
        }
    }
}

#Preview {
    PrinterView()
        .environmentObject(PrinterDetails())
        .environmentObject(PaperDetails())
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperEAN())
        .environmentObject(PrinterAvailability())
        .environmentObject(TextProperties())
        .environmentObject(UISettingsProperties())
}

