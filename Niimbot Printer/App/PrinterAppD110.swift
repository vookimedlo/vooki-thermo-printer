//
//  PrinterAppD110.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import SwiftUI
import SwiftData
import os
import TipKit


@main
class PrinterAppD110: App, Notifiable, NotificationObservable {
    nonisolated
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PrinterAppD110.self)
    )
    
    @PrinterActor
    private var printer: Printer? {
        willSet {
            Task { @MainActor in
                printerAvailability.isAvailable = (newValue != nil)
            }
        }
    }
    
    @PrinterActor
    private var printerDevice: PrinterDevice?
    @PrinterActor
    private var uplinkProcessor: UplinkProcessor?
    @PrinterActor
    private var bluetoothSupport = BluetoothSupport()
    
    var notificationListenerTask: Task<Void, Never>? = nil
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    required init() {
        if TestHelper.isRunningTests {
            initForTesting()
        }
        else {
            initForProduction()
        }
    }
    
    private func initForTesting() {
    }
    
    private func initForProduction() {
        notificationListenerTask = Task.detached {
            for await _ in NotificationCenter.default.notifications(named: .App.textPropertiesUpdated) {
                let paperEAN = await self.toSendable(self.paperEAN)
                if let preview = await self.generateImage(paperSize: paperEAN.printableSizeInPixels, margin: paperEAN.margin, from: self.toSendable(self.textProperties))?.cgImage {
                    await MainActor.run {
                        self.imagePreview.image = preview
                    }
                }
            }
        }
        
        try? Tips.resetDatastore()
        try? Tips.configure()
        
        for name in [Notification.Name.App.bluetoothPeripheralDisconnected,
                     Notification.Name.App.bluetoothPeripheralDiscovered] {
            registerNotification(name: name,
                                 selector: #selector(receiveBluetoothNotification))
        }
        
        for name in [Notification.Name.App.startPopulatingPeripherals,
                     Notification.Name.App.stopPopulatingPeripherals,
                     Notification.Name.App.selectedPeripheral,
                     Notification.Name.App.lastSelectedPeripheral,
                     Notification.Name.App.disconnectPeripheral,
                     Notification.Name.App.printRequested,
                     Notification.Name.App.paperDetect] {
            registerNotification(name: name,
                                 selector: #selector(receiveUINotification))
        }
        
        for name in [Notification.Name.App.serialNumber,
                     Notification.Name.App.softwareVersion,
                     Notification.Name.App.hardwareVersion,
                     Notification.Name.App.batteryInformation,
                     Notification.Name.App.deviceType,
                     Notification.Name.App.rfidData,
                     Notification.Name.App.noPaper,
                     Notification.Name.App.startPrint,
                     Notification.Name.App.startPagePrint,
                     Notification.Name.App.endPrint,
                     Notification.Name.App.endPagePrint,
                     Notification.Name.App.setDimension,
                     Notification.Name.App.setLabelType,
                     Notification.Name.App.setLabelDensity,
                     Notification.Name.App.getPrintStatus] {
            registerNotification(name: name,
                                 selector: #selector(receivePrinterNotification))
        }
        
        Task {
            await generateImagePreview()
        }
        //            printer?.getAutoShutdownTime()
        //            printer?.getDensity()
        //            printer?.getLabelType()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var bluetoothPepripherals = BluetoothPeripherals()
    @State private var paperDetails = PaperDetails()
    @State private var printerDetails = PrinterDetails()
    @State private var imagePreview = ImagePreview()
    @State private var paperEAN = ObservablePaperEAN()
    @State private var printerAvailability = PrinterAvailability()
    @State private var textProperties = TextProperties()
    
    @State private var connectionViewProperties = ConnectionViewProperties()
    @State private var uiSettingsProperties = UISettingsProperties()
        
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
            }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            PrinterMenuCommands(printerAvailability: printerAvailability,
                                connectionViewProperties: connectionViewProperties)
            LabelMenuCommands(paperEAN: paperEAN,
                              textProperties: textProperties,
                              printerAvailability: printerAvailability)
            ShowMenuCommands(uiSettingsProperties: uiSettingsProperties)
        }
    }
    
    @MainActor
    @objc func receiveUINotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        
        if Notification.Name.App.startPopulatingPeripherals == notification.name {
            Self.logger.info("Populating peripherals")
            Task { @PrinterActor in
                bluetoothSupport.startScanning()
            }
        }
        else if Notification.Name.App.stopPopulatingPeripherals == notification.name {
            Self.logger.info("Stop populating peripherals")
            Task { @PrinterActor in
                bluetoothSupport.stopScanning()
            }
        }
        else if Notification.Name.App.selectedPeripheral == notification.name {
            let uuid = notification.userInfo?[Notification.Keys.value] as! UUID
            Self.logger.info("Selected peripheral \(uuid.uuidString)")
            guard let peripheral = bluetoothPepripherals.find(identifier: uuid)?.peripheral else { return }
            Task { @PrinterActor in
                printerDevice = PrinterDevice(io: BluetoothIO(bluetoothAccess: BluetoothSupport(peripheral: peripheral)))
                printer = Printer(printerDevice: printerDevice!)
                connect()
            }
        }
        else if Notification.Name.App.lastSelectedPeripheral == notification.name {
            Self.logger.info("Last selected peripheral")
            Task { @PrinterActor in
                connect()
            }
        }
        else if Notification.Name.App.disconnectPeripheral ==  notification.name {
            Self.logger.info("Disconnecting peripheral")
            Task { @PrinterActor in
                printerDevice?.close()
                uplinkProcessor?.stopProcessing()
            }
        }
        else if Notification.Name.App.printRequested == notification.name {
            Self.logger.info("Print requested")
            Task { @PrinterActor in
                printLabel()
            }
        }
        else if Notification.Name.App.paperDetect == notification.name {
            Self.logger.info("Print detection requested")
            Task { @PrinterActor in
                printer?.getRFIDData()
            }
        }
    }
    
    @PrinterActor
    @objc func receiveBluetoothNotification(_ notification: Notification) {
        let rawValue = notification.name.rawValue
        Task { @MainActor in
            Self.logger.info("Notification \(rawValue) received")
        }
        
        if Notification.Name.App.bluetoothPeripheralDiscovered ==  notification.name {
            let value = notification.userInfo?[Notification.Keys.peripheral] as! BluetoothPeripheral
            Task { @MainActor in
                Self.logger.info("Bluetooth peripheral \(value.identifier)")
                self.bluetoothPepripherals.add(peripheral: value)
            }
        }
        else if Notification.Name.App.bluetoothPeripheralDisconnected ==  notification.name {
            Self.logger.info("Bluetooth peripheral disconnected")
            printerDevice?.close()
            uplinkProcessor?.stopProcessing()
            Task { @MainActor in
                printerAvailability.isConnected = false
                printerDetails.clear()
                paperDetails.clear()
            }
        }
    }
    
    @PrinterActor
    @objc func receivePrinterNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        
        if Notification.Name.App.serialNumber ==  notification.name {
            let serial_number = notification.userInfo?[Notification.Keys.value] as! String
            Task { @MainActor in
                Self.logger.info("Serial number: \(serial_number)")
                self.printerDetails.serialNumber = serial_number
            }
        }
        else if Notification.Name.App.softwareVersion ==  notification.name {
            let software_version = notification.userInfo?[Notification.Keys.value] as! Float
            Task { @MainActor in
                Self.logger.info("Software version: \(software_version)")
                self.printerDetails.softwareVersion = String(software_version)
            }
        }
        else if Notification.Name.App.hardwareVersion ==  notification.name {
            let hardware_version = notification.userInfo?[Notification.Keys.value] as! Float
            Task { @MainActor in
                Self.logger.info("Hardware version: \(hardware_version)")
            }
        }
        else if Notification.Name.App.batteryInformation ==  notification.name {
            let battery_information = notification.userInfo?[Notification.Keys.value] as! UInt8
            Task { @MainActor in
                Self.logger.info("Battery information: \(battery_information)")
                self.printerDetails.batteryLevel = Int(battery_information)
            }
        }
        else if Notification.Name.App.deviceType ==  notification.name {
            let device_type = notification.userInfo?[Notification.Keys.value] as! UInt16
            Task { @MainActor in
                Self.logger.info("Device type: \(device_type)")
                self.printerDetails.deviceType = 2304 == device_type ? "D110" : String(device_type)
            }
        }
        else if Notification.Name.App.rfidData ==  notification.name {
            let rfidData = notification.userInfo?[Notification.Keys.value] as! RFIDData
            Task { @MainActor in
                Self.logger.info("RFID data - UDID: \(rfidData.uuid.hexEncodedString())")
                Self.logger.info("RFID data - Barcode: \(rfidData.barcode)")
                Self.logger.info("RFID data - Serial: \(rfidData.serial)")
                Self.logger.info("RFID data - Total labels: \(rfidData.totalLength)")
                Self.logger.info("RFID data - Used labels: \(rfidData.usedLength)")
                Self.logger.info("RFID data - Type: \(rfidData.type)")
                
                self.paperEAN.ean = PaperEAN(rawValue: rfidData.barcode) ?? .unknown
                notifyUI(name: .App.paperChanged, userInfo: [String : any Sendable](dictionaryLiteral: (Notification.Keys.value, self.paperEAN.ean)))
                
                self.paperDetails.remainingCount = String(rfidData.totalLength - rfidData.usedLength)
                self.paperDetails.printedCount = String(rfidData.usedLength)
                self.paperDetails.barcode = rfidData.barcode
                self.paperDetails.serialNumber = rfidData.serial
                self.paperDetails.type = String(rfidData.type)
                self.paperDetails.color = paperEAN.ean.color
                self.paperDetails.colorName = paperEAN.ean.colorName

                self.printerDetails.isPaperInserted = true
                await generateImagePreview()
            }
        }
        else if Notification.Name.App.noPaper ==  notification.name {
            Task { @MainActor in
                Self.logger.info("No paper")
                self.printerDetails.isPaperInserted = false
            }
        }
        else if Notification.Name.App.startPrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                Self.logger.info("StartPrint \(value)")
            }
        }
        else if Notification.Name.App.startPagePrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                Self.logger.info("StartPagePrint \(value)")
            }
        }
        else if Notification.Name.App.endPrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                Self.logger.info("EndPrint \(value)")
            }
        }
        else if Notification.Name.App.endPagePrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                Self.logger.info("EndPagePrint \(value)")
            }
        }
        else if Notification.Name.App.setDimension == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                Self.logger.info("SetDimension \(value)")
            }
        }
        else if Notification.Name.App.setLabelType == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                Self.logger.info("SetLabelType \(value)")
            }
        }
        else if Notification.Name.App.setLabelDensity == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Task { @MainActor in
                
                Self.logger.info("SetLabelDensity \(value)")
            }
        }
        else if Notification.Name.App.getPrintStatus == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! PrintStatus
            Task { @MainActor in
                Self.logger.info("GetPrintStatus - Page: \(value.page)")
                Self.logger.info("GetPrintStatus - Progress 1: \(value.progress1)")
                Self.logger.info("GetPrintStatus - Progress 2: \(value.progress2)")
                
                notifyUI(name: .App.UI.printPrintingProgress,
                         userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, value.progress1)))
                
                if value.progress2 == 100 {
                    notify(name: .App.printFinished,
                           userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, true)))
                }
            }
        }
    }
    
    @PrinterActor
    func connect() {
        do {
            if uplinkProcessor != nil {
                uplinkProcessor?.cancel()
            }
            try printerDevice?.open()
            let name = printerDevice?.io.name ?? ""
            Task { @MainActor in
                printerDetails.name = name
                printerAvailability.isConnected = true
                Self.logger.info("Open")
            }
            self.uplinkProcessor = UplinkProcessor(printerDevice: self.printerDevice!)
            self.uplinkProcessor?.startProcessing()
            printer?.getBatteryInformation()
            printer?.getSerialNumber()
            printer?.getSoftwareVersion()
            printer?.getHardwareVersion()
            printer?.getDeviceType()
            printer?.getRFIDData()
            printer?.getPrintStatus()
        } catch IOError.open {
            Self.logger.error("Open failed")
        } catch {
            Self.logger.error("Open failed - unknown failure")
        }
    }
    
    @ImageActor
    private func generateImage(paperSize: CGSize, margin: Margins, from properties: [SendableTextProperty]) async -> ImageGenerator? {
        guard let image = ImageGenerator(size: paperSize, margin: margin) else { return nil }
        for (index, property) in properties.enumerated() {
            switch property.whatToPrint {
            case .text:
                guard !property.text.isEmpty else { continue }
                await image.drawText(text: property.text,
                                     fontName: property.fontName,
                                     fontSize: property.fontSize,
                                     horizontal: property.horizontalAlignment,
                                     vertical: property.verticalAlignment,
                                     margin: property.margin)
            case .qr:
                guard !property.text.isEmpty else { continue }
                await image.generateQRCode(text: property.text,
                                           size: property.squareCodeSize,
                                           horizontal: property.horizontalAlignment,
                                           vertical: property.verticalAlignment,
                                           margin: property.margin)
            case .image:
                switch (property.imageDecoration) {
                case .custom:
                    guard !property.image.isEmpty else { continue }
                    image.drawImage(data: property.image)
                case .frame, .frame3, .frame4, .frame5:
                    fallthrough
                case .doubleFrame, .doubleFrame3, .doubleFrame4, .doubleFrame5:
                    let divider = property.imageDecoration.frameDivider
                    let isDoubleFrame = property.imageDecoration.isDoubleFrame
                    await image.drawBorder(divide_by: divider, doubleBorder: isDoubleFrame)
                    guard property.image.isEmpty else { continue }
                    guard let imagePreview = ImageGenerator(size: paperSize, margin: margin) else { continue }
                    await imagePreview.drawBorder(divide_by: divider, doubleBorder: isDoubleFrame)
                    let data = await imagePreview.cgImage?.data ?? Data()
                    await MainActor.run {
                        textProperties.properties[index].image = data
                    }
                }
            }
        }
        return image
    }
    
    private func toSendable(_ textProperties: TextProperties) -> [SendableTextProperty] {
        var result = [SendableTextProperty]()
        for property in textProperties.properties {
            result.append(SendableTextProperty(from: property))
        }
        return result
    }
    
    private func toSendable(_ paperEAN: ObservablePaperEAN) -> PaperEAN {
        return paperEAN.ean
    }
    
    private func generateImagePreview() async {
        let properties = toSendable(textProperties)
        let paperEAN = self.toSendable(self.paperEAN)
        guard let preview = await self.generateImage(paperSize: paperEAN.printableSizeInPixels, margin: paperEAN.margin, from: properties)?.cgImage else { return }
        self.imagePreview.image = preview
    }
    
    private func preparePrintData() async  -> [[UInt8]] {
        let properties = toSendable(textProperties)
        let paperEAN = self.toSendable(self.paperEAN)
        guard let data = await self.generateImage(paperSize: paperEAN.printableSizeInPixels, margin: paperEAN.margin, from: properties)?.printerData else { return [] }
        
        var peparedData: [[UInt8]] = []
        var rowNumber: UInt16 = 0
        for rowBytes in data {
            let bitsPerByte = UInt8.bitWidth
            let remainingBitCount = rowBytes.count % bitsPerByte
            guard remainingBitCount == 0 else {
                Self.logger.error("Cannot be byte aligned -  remaining bit count: \(remainingBitCount)")
                return []
            }
            
            let bytesCount = UInt16(rowBytes.count / bitsPerByte)
            var resultingData: [UInt8] = rowNumber.bigEndian.bytes + [0, 0, 0, 1]
            var offsetInRow = 0
            
            for _ in 0 ..< bytesCount {
                let bitsString = rowBytes[offsetInRow + 0 ..< offsetInRow + bitsPerByte].decEncodedString()
                guard let byte = UInt8(bitsString, radix: 2) else { return [] }
                resultingData.append(byte)
                offsetInRow += bitsPerByte
            }
            rowNumber += 1
            peparedData.append(resultingData)
        }
        return peparedData
    }
    
    @PrinterActor
    private func executePrintCommands() async {
        do {
            let data = await preparePrintData()
            guard !data.isEmpty else { return }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
                await self.printer?.setLabelDensity(density: 1)
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPrint) {
                await self.printer?.startPrint()
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPagePrint) {
                await self.printer?.startPagePrint()
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.setDimension) {
                await self.printer?.setDimension(width: UInt16(self.paperEAN.ean.printableSizeInPixels.width),
                                                 height: UInt16(self.paperEAN.ean.printableSizeInPixels.height))
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
                await self.printer?.setLabelDensity(density: 1)
            }
            
            let max = data.count
            var currentStep = 1
            for packet in data {
                printer?.setPrinterData(data: packet)
                notifyUI(name: .App.UI.printSendingProgress,
                         userInfo: [String : Sendable](dictionaryLiteral: (Notification.Keys.value, currentStep != max ? Double(currentStep) / Double(max) * 100.0 : 100.0)))
                currentStep += 1
                try? await Task.sleep(for: .milliseconds(50),
                                      tolerance: .milliseconds(25))
            }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPagePrint) {
                await self.printer?.endPagePrint()
            }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.printFinished,
                                                        timeout: .seconds(10)) {
                while !Task.isCancelled {
                    await self.printer?.getPrintStatus()
                    try await Task.sleep(for: .milliseconds(50))
                }
            }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPrint) {
                await self.printer?.endPrint()
            }
            
            printer?.getRFIDData()
        }
        catch {
            Self.logger.error("Something went wrong when printing")
            notifyUIAlert(alertType: .printError)
        }
    }
    
    @PrinterActor
    private func printLabel() {
        notifyUI(name: .App.UI.printStarted)
        Task {
            defer {
                self.notifyUI(name: .App.UI.printDone)
            }
            await self.executePrintCommands()
        }
    }
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
