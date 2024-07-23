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
    
    private let controlDisabledColor = Color(NSColor.disabledControlTextColor)

    
    var body: some View {
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
            
            TextTabView().padding([.horizontal, .bottom])
            
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
