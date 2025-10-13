//
//  PrinterAppBase.swift
//  Niimbot Printer
//
//  Created by Refactor on 13.10.2025.
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

/// A reusable base type that contains all shared state and scene/command wiring.
/// Concrete app variants (e.g., D110, D11_H) should:
///  - Provide their `dpi` value
///  - Initialize `appLogic` in their init
@MainActor
class PrinterAppBase: ObservableObject, AppStates {
    // MARK: - Variant configuration
    let dpi: PaperEAN.DPI

    // MARK: - Optional logic owned by variants
    var appLogic: AppLogic?

    // MARK: - Shared SwiftData container
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

    // MARK: - Shared state objects
    @State public var bluetoothPepripherals = BluetoothPeripherals()
    @State public var paperDetails = PaperDetails()
    @State public var printerDetails = PrinterDetails()
    @State public var imagePreview = ImagePreview()
    @State public var paperEAN = ObservablePaperEAN()
    @State public var printerAvailability = PrinterAvailability()
    @State public var textProperties = TextProperties()

    @State public var connectionViewProperties = ConnectionViewProperties()
    @State public var uiSettingsProperties = UISettingsProperties()

    // MARK: - Init
    init(dpi: PaperEAN.DPI) {
        self.dpi = dpi
    }

    // MARK: - Root scene content used by variants
    @ViewBuilder
    func rootContentView() -> some View {
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

    // MARK: - Commands builder used by variants
    @CommandsBuilder
    func commandsBuilder() -> some Commands {
        @Bindable var printerAvailability = self.printerAvailability
        @Bindable var connectionViewProperties = self.connectionViewProperties
        @Bindable var uiSettingsProperties = self.uiSettingsProperties
        @Bindable var paperEAN = self.paperEAN
        @Bindable var textProperties = self.textProperties

        CommandGroup(replacing: .appInfo) { }

        PrinterMenuCommands(printerAvailability: printerAvailability,
                            connectionViewProperties: connectionViewProperties)
        LabelMenuCommands(paperEAN: paperEAN,
                          textProperties: textProperties,
                          printerAvailability: printerAvailability)
        ShowMenuCommands(uiSettingsProperties: uiSettingsProperties)
    }
}
