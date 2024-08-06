//
//  PrinterView.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 12.06.2024.
//

import SwiftUI


struct PrinterView: View, Notifiable {
    @Environment(PrinterAvailability.self) private var printerAvailability
    @Environment(PrinterDetails.self) private var printeDetails
    
    @State private var showingInspector: Bool = true
    @State private var showingPrintingProgress: Bool = false
    
    @State private var selectedTextProperty: TextProperty?
    @State var horizontalMargin: HorizontalMargin = HorizontalMargin.none
    @State var verticalMargin: VerticalMargin = VerticalMargin.none
    
    private let controlDisabledColor = Color(NSColor.disabledControlTextColor)

    var body: some View {
        VStack {
            GroupBox {
                ZStack {
                    VStack {
                        Spacer()
                        HStack{
                            Spacer()
                            Preview(horizontalMargin: $horizontalMargin,
                                    verticalMargin: $verticalMargin)
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
                                    Text("Printable area").foregroundStyle(.red)
                                    Text("Physical area").foregroundStyle(.green)
                                }
                            }.padding(10)
                        }
                    }
                }
            } label: {
                Text("Paper preview")
            }.padding()
            
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
            
            HStack {
                Button {
                    notifyUI(name: Notification.Name.App.printRequested)
                } label: {
                    Text("Print").fontWeight(.heavy)
                        .frame(minWidth: 200, maxWidth: .infinity).padding()
                }
                .background(printerAvailability.isConnected ? Color.accentColor : controlDisabledColor, in: .buttonBorder)
                .disabled(!printerAvailability.isConnected)
            }.padding(.horizontal, 250).padding(.bottom)
        }.navigationTitle("D110 Printer")
            .inspector(isPresented: $showingInspector) {
                VStack {
                    List {
                        Section(header: Text("Printer")) {
                            PrinterDetailsView()
                        }

                        if printerAvailability.isConnected && printeDetails.isPaperInserted {
                            Section(header: Text("Paper")) {
                                PrinterLabelDetailView()
                            }
                        }
                    }.listStyle(.sidebar)
                    Spacer()
                }
                .animation(.easeInOut, value: printerAvailability.isConnected)
                .animation(.easeInOut, value: printeDetails.isPaperInserted)
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
    
    private func computeHorizontalMargin() {
        guard let selectedTextProperty = selectedTextProperty else {
            horizontalMargin = HorizontalMargin.none
            return
        }
        switch selectedTextProperty.whatToPrint {
        case .text, .qr:
            switch selectedTextProperty.horizontalAlignment.alignment {
            case .left:
                let margin = selectedTextProperty.margin.leading
                horizontalMargin = margin >= 0 ? HorizontalMargin.leading(size: margin) : HorizontalMargin.none
            case .center:
                horizontalMargin = HorizontalMargin.none
            case .right:
                let margin = selectedTextProperty.margin.trailing
                horizontalMargin = margin >= 0 ? HorizontalMargin.trailing(size: margin) : HorizontalMargin.none
            }
        case .image:
            horizontalMargin = HorizontalMargin.none
        }
    }
    
    private func computeVerticalMargin() {
        guard let selectedTextProperty = selectedTextProperty else {
            verticalMargin = VerticalMargin.none
            return
        }
        switch selectedTextProperty.whatToPrint {
        case .text, .qr:
            switch selectedTextProperty.verticalAlignment.alignment {
            case .bottom:
                let margin = selectedTextProperty.margin.bottom
                verticalMargin = margin >= 0 ? VerticalMargin.bottom(size: margin) : VerticalMargin.none
            case .center:
                verticalMargin = VerticalMargin.none
            case .top:
                let margin = selectedTextProperty.margin.top
                verticalMargin = margin >= 0 ? VerticalMargin.top(size: margin) : VerticalMargin.none
            }
        case .image:
            verticalMargin = VerticalMargin.none
        }
    }
}

#Preview {
    PrinterView()
        .environmentObject(PrinterDetails())
        .environmentObject(PaperDetails())
        .environmentObject(ImagePreview())
        .environmentObject(ObservablePaperType())
        .environmentObject(PrinterAvailability())
        .environmentObject(TextProperties())
}
