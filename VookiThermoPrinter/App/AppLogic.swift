//
//  AppLogic.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.10.2024.
//

import Foundation
import SwiftData
import TipKit
import os

@MainActor
final class AppLogic: Notifiable, NotificationObservable {
    nonisolated
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PrinterAppBase.self)
    )
    
    @PrinterActor
    var printer: Printer? {
        willSet {
            Task { @MainActor in
                self.appRef.printerAvailability.isAvailable = (newValue != nil)
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
    
    @MainActor
    var appRef: AppStates!
    var dpi: PaperEAN.DPI!
    init(appRef: inout PrinterAppBase, dpi: PaperEAN.DPI) {
        self.appRef = appRef
        self.dpi = dpi
        
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
                let properties = await self.toSendable(self.appRef.textProperties)
                let paperEAN = await self.toSendable(self.appRef.paperEAN)
                guard let cgImage = await self.generateImage(paperSize: paperEAN.printableSizeInPixels(dpi: self.dpi), margin: paperEAN.margin, from: properties)?.cgImage else { return }
                await MainActor.run {
                    self.appRef.imagePreview.image = cgImage
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
                     Notification.Name.App.paperDetect,
                     Notification.Name.App.historyRemoveAll,
                     Notification.Name.App.historyKeepRecords,
                     Notification.Name.App.historyRemoveOlderRecords,
                     Notification.Name.App.loadHistoricalItem,
                     Notification.Name.App.deleteHistoricalItem,
                     Notification.Name.App.deleteSavedItem] {
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
            guard let peripheral = appRef.bluetoothPepripherals.find(identifier: uuid)?.peripheral else { return }
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
            Task { @MainActor in
                guard let imageGenerator = await generateImagePreview(propagate: false) else { return }
                guard let pngRepresentation = await imageGenerator.pngRepresentation() else { return }
                let labelProperty = SDHistoryLabelProperty(textProperties: toSendable(self.appRef.textProperties),
                                                           pngImage: pngRepresentation,
                                                           paperEANRawValue: self.appRef.paperEAN.ean.rawValue)
                self.appRef.container.mainContext.insert(labelProperty)
            }
            Task { @PrinterActor in
                printLabel()
            }
        }
        else if Notification.Name.App.paperDetect == notification.name {
            Self.logger.info("Print detection requested")
            Task {
                if await PrinterActor.printerOperation({try self.printer?.getRFIDData()}) == false {
                    notifyUIAlert(alertType: .communicationError)
                }
            }
        }
        else if Notification.Name.App.loadHistoricalItem == notification.name {
            Self.logger.info("Load data from history requested")
            let identifier = notification.userInfo?[Notification.Keys.value] as! PersistentIdentifier
            guard let item = appRef.container.mainContext.model(for: identifier) as? any SDLabelProperty else { return }
            appRef.textProperties.properties = (item.orderedTextProperties?.map { sdTextProperty in
                sdTextProperty.toTextProperty()
            })!
            notifyUI(name: .App.textPropertiesUpdated)
            notifyUI(name: .App.showView,
                     userInfo: [String : any Sendable] (dictionaryLiteral: (Notification.Keys.value, ContentView.Views.printerView)))
        }
        else if Notification.Name.App.deleteHistoricalItem == notification.name {
            Self.logger.info("Delete data from history requested")
            let identifier = notification.userInfo?[Notification.Keys.value] as! PersistentIdentifier
            do {
                try appRef.container.mainContext.delete(model: SDHistoryLabelProperty.self, where: #Predicate { input in
                    input.persistentModelID == identifier
                })
            }
            catch {
                Self.logger.error("Cannot delete historical data")
            }
        }
        else if Notification.Name.App.deleteSavedItem == notification.name {
            Self.logger.info("Delete saved data requested")
            let identifier = notification.userInfo?[Notification.Keys.value] as! PersistentIdentifier
            do {
                try appRef.container.mainContext.delete(model: SDSavedLabelProperty.self, where: #Predicate { input in
                    input.persistentModelID == identifier
                })
            }
            catch {
                Self.logger.error("Cannot delete saved data")
            }
        }
        else if Notification.Name.App.historyRemoveAll == notification.name {
            Self.logger.info("Remove all historical records requested")
            do {
                try appRef.container.mainContext.delete(model: SDHistoryLabelProperty.self)
            }
            catch {
                Self.logger.error("Cannot remove historical data")
            }
        }
        else if Notification.Name.App.historyRemoveOlderRecords == notification.name {
            Self.logger.info("Remove older historical records requested")
            do {
                let days = notification.userInfo?[Notification.Keys.value] as! Int
                let twentyDaysInPast = Calendar(identifier: .gregorian).date(
                    byAdding: .day,
                    value: -days,
                    to: Date()
                )!
                try appRef.container.mainContext.delete(model: SDHistoryLabelProperty.self, where: #Predicate { input in
                    input.date < twentyDaysInPast
                })
            }
            catch {
                Self.logger.error("Cannot remove historical data")
            }
        }
        else if Notification.Name.App.historyKeepRecords == notification.name {
            Self.logger.info("Keeping historical records requested")
            do {
                let numberOfItemsToBeKept = notification.userInfo?[Notification.Keys.value] as! Int
                try appRef.container.mainContext.transaction {
                    let fetchDescriptor = FetchDescriptor<SDHistoryLabelProperty>(sortBy: [SortDescriptor<SDHistoryLabelProperty>(\SDHistoryLabelProperty.date, order: SortOrder.forward)])
                    let fetchCount = try appRef.container.mainContext.fetchCount(fetchDescriptor)
                    let numberOfItemsToBeRemoved = fetchCount > numberOfItemsToBeKept ? fetchCount - numberOfItemsToBeKept : 0
                    let itemsToBeRemoved = try appRef.container.mainContext.fetch(fetchDescriptor)
                    for item in itemsToBeRemoved[0..<numberOfItemsToBeRemoved] {
                        appRef.container.mainContext.delete(item)
                    }
                }
            }
            catch {
                Self.logger.error("Cannot remove historical data")
            }
        }
    }
    
    @PrinterActor
    @objc func receiveBluetoothNotification(_ notification: Notification) {
        let rawValue = notification.name.rawValue
        PrinterActor.onMain(Self.logger.info("Notification \(rawValue) received"))
        
        if Notification.Name.App.bluetoothPeripheralDiscovered ==  notification.name {
            let value = notification.userInfo?[Notification.Keys.peripheral] as! BluetoothPeripheral
            Task { @MainActor in
                Self.logger.info("Bluetooth peripheral \(value.identifier)")
                appRef.bluetoothPepripherals.add(peripheral: value)
            }
        }
        else if Notification.Name.App.bluetoothPeripheralDisconnected ==  notification.name {
            PrinterActor.onMain(Self.logger.info("Bluetooth peripheral disconnected"))
            printerDevice?.close()
            uplinkProcessor?.stopProcessing()
            Task { @MainActor in
                self.appRef.printerAvailability.isConnected = false
                self.appRef.printerDetails.clear()
                self.appRef.paperDetails.clear()
            }
        }
    }
    
    @PrinterActor
    @objc func receivePrinterNotification(_ notification: Notification) {
        let rawValue = notification.name.rawValue
        PrinterActor.onMain(Self.logger.info("Notification \(rawValue) received"))
        
        if Notification.Name.App.serialNumber ==  notification.name {
            let serial_number = notification.userInfo?[Notification.Keys.value] as! String
            Task { @MainActor in
                Self.logger.info("Serial number: \(serial_number)")
                self.appRef.printerDetails.serialNumber = serial_number
            }
        }
        else if Notification.Name.App.softwareVersion ==  notification.name {
            let software_version = notification.userInfo?[Notification.Keys.value] as! Float
            Task { @MainActor in
                Self.logger.info("Software version: \(software_version)")
                self.appRef.printerDetails.softwareVersion = String(software_version)
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
                self.appRef.printerDetails.batteryLevel = Int(battery_information)
            }
        }
        else if Notification.Name.App.deviceType ==  notification.name {
            let device_type = notification.userInfo?[Notification.Keys.value] as! UInt16
            Task { @MainActor in
                Self.logger.info("Device type: \(device_type)")
                switch device_type {
                case 2304:
                    Self.logger.info("Device type: D110")
                    self.appRef.printerDetails.deviceType = "D110"
                case 528:
                    Self.logger.info("Device type: D11_H")
                    self.appRef.printerDetails.deviceType = "D11_H"
                default:
                    Self.logger.info("Device type: Unknown")
                    self.appRef.printerDetails.deviceType = String(device_type)
                }
                
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
                
                self.appRef.paperEAN.ean = PaperEAN(rawValue: rfidData.barcode) ?? .unknown
                notifyUI(name: .App.paperChanged, userInfo: [String : any Sendable](dictionaryLiteral: (Notification.Keys.value, self.appRef.paperEAN.ean)))
                
                self.appRef.paperDetails.remainingCount = String(rfidData.totalLength - rfidData.usedLength)
                self.appRef.paperDetails.printedCount = String(rfidData.usedLength)
                self.appRef.paperDetails.barcode = rfidData.barcode
                self.appRef.paperDetails.serialNumber = rfidData.serial
                self.appRef.paperDetails.type = String(rfidData.type)
                self.appRef.paperDetails.color = self.appRef.paperEAN.ean.color
                self.appRef.paperDetails.colorName = self.appRef.paperEAN.ean.colorName
                
                self.appRef.printerDetails.isPaperInserted = true
                await generateImagePreview()
            }
        }
        else if Notification.Name.App.noPaper ==  notification.name {
            Task { @MainActor in
                Self.logger.info("No paper")
                self.appRef.printerDetails.isPaperInserted = false
            }
        }
        else if Notification.Name.App.startPrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("StartPrint \(value)"))
        }
        else if Notification.Name.App.startPagePrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("StartPagePrint \(value)"))
        }
        else if Notification.Name.App.endPrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("EndPrint \(value)"))
        }
        else if Notification.Name.App.endPagePrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("EndPagePrint \(value)"))
        }
        else if Notification.Name.App.setDimension == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("SetDimension \(value)"))
        }
        else if Notification.Name.App.setLabelType == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("SetLabelType \(value)"))
        }
        else if Notification.Name.App.setLabelDensity == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            PrinterActor.onMain(Self.logger.info("SetLabelDensity \(value)"))
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
                self.appRef.printerDetails.name = name
                self.appRef.printerAvailability.isConnected = true
                Self.logger.info("Open")
            }
            self.uplinkProcessor = UplinkProcessor(printerDevice: self.printerDevice!)
            self.uplinkProcessor?.startProcessing()
            try printer?.getBatteryInformation()
            try printer?.getSerialNumber()
            try printer?.getSoftwareVersion()
            try printer?.getHardwareVersion()
            try printer?.getDeviceType()
            try printer?.getRFIDData()
            try printer?.getPrintStatus()
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
                        self.appRef.textProperties.properties[index].image = data
                    }
                }
            }
        }
        return image
    }
    
    @MainActor
    private func toSendable(_ textProperties: TextProperties) -> [SendableTextProperty] {
        var result = [SendableTextProperty]()
        for property in textProperties.properties {
            result.append(SendableTextProperty(from: property))
        }
        return result
    }
    
    @MainActor
    private func toSendable(_ paperEAN: ObservablePaperEAN) -> PaperEAN {
        return paperEAN.ean
    }
    
    @MainActor
    @discardableResult
    private func generateImagePreview(propagate: Bool = true) async -> ImageGenerator? {
        let properties = toSendable(self.appRef.textProperties)
        let paperEAN = self.toSendable(self.appRef.paperEAN)
        guard let preview = await self.generateImage(paperSize: paperEAN.printableSizeInPixels(dpi: self.dpi), margin: paperEAN.margin, from: properties) else { return nil }
        
        if (propagate) {
            guard let cgImage = await preview.cgImage else { return nil }
            self.appRef.imagePreview.image = cgImage
            return nil
        }
        return preview
    }
    
    func preparePrintData() async  -> [[UInt8]] {
        let properties = toSendable(self.appRef.textProperties)
        let paperEAN = self.toSendable(self.appRef.paperEAN)
        guard let data = await self.generateImage(paperSize: paperEAN.printableSizeInPixels(dpi: self.dpi), margin: paperEAN.margin, from: properties)?.printerData else { return [] }
        
        var preparedData: [[UInt8]] = []
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
            preparedData.append(resultingData)
        }
        return preparedData
    }
    
    @PrinterActor
    private func printLabel() {
        notifyUI(name: .App.UI.printStarted)
        Task {
            defer {
                self.notifyUI(name: .App.UI.printDone)
            }
            do {
                try await self.executePrintCommands()
            }
            catch {
                Self.logger.error("Something went wrong when printing")
                notifyUIAlert(alertType: .printError)
            }
        }
    }
}

protocol AppLogicPrinting {
    @PrinterActor
    func executePrintCommands() async throws
}

