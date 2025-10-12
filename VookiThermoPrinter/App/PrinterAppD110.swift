//
//  PrinterAppD110.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import SwiftUI
import SwiftData

@MainActor
protocol AppStates: Sendable {
    var bluetoothPepripherals: BluetoothPeripherals { get }
    var paperDetails: PaperDetails { get }
    var printerDetails: PrinterDetails { get }
    var imagePreview: ImagePreview { get }
    var paperEAN: ObservablePaperEAN { get }
    var printerAvailability: PrinterAvailability { get }
    var textProperties: TextProperties { get }
    
    var connectionViewProperties: ConnectionViewProperties { get }
    var uiSettingsProperties: UISettingsProperties { get }
    
    var container: ModelContainer { get }
}

@main
struct PrinterAppD110: App, AppStates {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let dpi = PaperEAN.DPI.dpi203
    
    var appLogic: AppLogic?
    init() {
        if !TestHelper.isRunningTests {
            appLogic = AppLogic(appRef: &self, dpi: dpi)
        }
    }
    
    let container: ModelContainer = {
        let schema = Schema([SDHistoryLabelProperty.self, SDSavedLabelProperty.self])
        
        let configuration = {
            if TestHelper.isRunningTests {
                ModelConfiguration(isStoredInMemoryOnly: true)
            }
            else {
                ModelConfiguration(isStoredInMemoryOnly: false)
            }
        }()
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State public var bluetoothPepripherals = BluetoothPeripherals()
    @State public var paperDetails = PaperDetails()
    @State public var printerDetails = PrinterDetails()
    @State public var imagePreview = ImagePreview()
    @State public var paperEAN = ObservablePaperEAN()
    @State public var printerAvailability = PrinterAvailability()
    @State public var textProperties = TextProperties()
    
    @State public var connectionViewProperties = ConnectionViewProperties()
    @State public var uiSettingsProperties = UISettingsProperties()
    
    var body: some Scene {
        @Bindable var printerAvailability = self.printerAvailability
        @Bindable var connectionViewPropertie = self.connectionViewProperties
        
        WindowGroup { [self] in
            if TestHelper.isRunningTests {
                EmptyView()
            } else {
                ContentView()
                    .environmentObject(self.bluetoothPepripherals)
                    .environmentObject(self.printerDetails)
                    .environmentObject(self.paperDetails)
                    .environmentObject(self.imagePreview)
                    .environmentObject(self.paperEAN)
                    .environmentObject(self.printerAvailability)
                    .environmentObject(self.textProperties)
                    .environmentObject(self.connectionViewProperties)
                    .environmentObject(self.uiSettingsProperties)
                    .environment(\.dpi, dpi)
            }
        }
        .modelContainer(container)
        .commands {
            PrinterMenuCommands(printerAvailability: printerAvailability,
                                connectionViewProperties: connectionViewProperties)
            LabelMenuCommands(paperEAN: paperEAN,
                              textProperties: textProperties,
                              printerAvailability: printerAvailability)
            ShowMenuCommands(uiSettingsProperties: uiSettingsProperties)
        }
    }
}
