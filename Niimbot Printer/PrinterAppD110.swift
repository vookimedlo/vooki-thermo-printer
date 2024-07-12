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
class PrinterAppD110: App, Notifier, NotificationObservable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PrinterAppD110.self)
    )

    private var printer: Printer? {
        willSet {
            printerAvailability.isAvailable = (newValue != nil)
        }
    }
    private var printerDevice: PrinterDevice?
    private var uplinkProcessor: UplinkProcessor?
    
    private var bluetoothSupport: BluetoothSupport
        
    required init() {
        bluetoothSupport = BluetoothSupport()
        try? Tips.resetDatastore()
        try? Tips.configure()
        
        for name in [Notification.Name.App.textPropertiesUpdated,
                     Notification.Name.App.printRequested] {
            registerNotification(name: name,
                                       selector: #selector(receiveNotification))
        }

        for name in [Notification.Name.App.startPopulatingPeripherals,
                     Notification.Name.App.stopPopulatingPeripherals,
                     Notification.Name.App.disconnectPeripheral,
                     Notification.Name.App.selectedPeripheral,
                     Notification.Name.App.lastSelectedPeripheral,
                     Notification.Name.App.bluetoothPeripheralDisconnected,
                     Notification.Name.App.bluetoothPeripheralDiscovered] {
            registerNotification(name: name,
                                       selector: #selector(receiveBluetoothNotification))
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
        
        generateImagePreview()
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
    @State private var paperType = ObservablePaperType()
    @State private var printerAvailability = PrinterAvailability()
    @State private var textProperties = TextProperties()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothPepripherals)
                .environmentObject(printerDetails)
                .environmentObject(paperDetails)
                .environmentObject(imagePreview)
                .environmentObject(paperType)
                .environmentObject(printerAvailability)
                .environmentObject(textProperties)
        }
        .modelContainer(sharedModelContainer)
    }
    
    @objc func receiveNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        
        if Notification.Name.App.textPropertiesUpdated == notification.name {
            Self.logger.info("Text properties updated")
            generateImagePreview()
        }
        else if Notification.Name.App.printRequested == notification.name {
            Self.logger.info("Print requested")
            printLabel()
        }
    }
    
    @objc func receiveBluetoothNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")

        if Notification.Name.App.bluetoothPeripheralDiscovered ==  notification.name {
            let value = notification.userInfo?[Notification.Keys.peripheral] as! BluetoothPeripheral
            Self.logger.info("Bluetooth peripheral \(value.identifier)")
            DispatchQueue.main.async {
                self.bluetoothPepripherals.add(peripheral: value)
            }
        }
        else if Notification.Name.App.disconnectPeripheral ==  notification.name {
            Self.logger.info("Disconnecting peripheral")
            printerDevice?.close()
            uplinkProcessor?.stopProcessing()
        }
        else if Notification.Name.App.bluetoothPeripheralDisconnected ==  notification.name {
            Self.logger.info("Bluetooth peripheral disconnected")
            printerDevice?.close()
            uplinkProcessor?.stopProcessing()
            printerAvailability.isConnected = false
            printerDetails.clear()
            paperDetails.clear()
        }
        else if Notification.Name.App.startPopulatingPeripherals == notification.name {
            Self.logger.info("Populating peripherals")
            bluetoothSupport.startScanning()
        }
        else if Notification.Name.App.stopPopulatingPeripherals == notification.name {
            Self.logger.info("Stop populating peripherals")
            bluetoothSupport.stopScanning()
        }
        else if Notification.Name.App.selectedPeripheral == notification.name {
            let uuid = notification.userInfo?[Notification.Keys.value] as! UUID
            Self.logger.info("Selected peripheral \(uuid.uuidString)")
            guard let peripheral = bluetoothPepripherals.find(identifier: uuid)?.peripheral else { return }
            printerDevice = PrinterDevice(io: BluetoothIO(bluetoothAccess: BluetoothSupport(peripheral: peripheral)))
            printer = Printer(printerDevice: printerDevice!)
            connect()
        }
        else if Notification.Name.App.lastSelectedPeripheral == notification.name {
            Self.logger.info("Last selected peripheral")
            connect()
        }
        
    }

    @objc func receivePrinterNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        
        if Notification.Name.App.serialNumber ==  notification.name {
            let serial_number = notification.userInfo?[Notification.Keys.value] as! String
            Self.logger.info("Serial number: \(serial_number)")
            DispatchQueue.main.async {
                self.printerDetails.serialNumber = serial_number
            }
        }
        else if Notification.Name.App.softwareVersion ==  notification.name {
            let software_version = notification.userInfo?[Notification.Keys.value] as! Float
            Self.logger.info("Software version: \(software_version)")
            DispatchQueue.main.async {
                self.printerDetails.softwareVersion = String(software_version)
            }
        }
        else if Notification.Name.App.hardwareVersion ==  notification.name {
            let hardware_version = notification.userInfo?[Notification.Keys.value] as! Float
            Self.logger.info("Hardware version: \(hardware_version)")
        }
        else if Notification.Name.App.batteryInformation ==  notification.name {
            let battery_information = notification.userInfo?[Notification.Keys.value] as! UInt8
            Self.logger.info("Battery information: \(battery_information)")
            DispatchQueue.main.async {
                self.printerDetails.batteryLevel = Int(battery_information)
            }
        }
        else if Notification.Name.App.deviceType ==  notification.name {
            let device_type = notification.userInfo?[Notification.Keys.value] as! UInt16
            Self.logger.info("Device type: \(device_type)")
            DispatchQueue.main.async {
                self.printerDetails.deviceType = 2304 == device_type ? "D110" : String(device_type)
            }
        }
        else if Notification.Name.App.rfidData ==  notification.name {
            let rfidData = notification.userInfo?[Notification.Keys.value] as! RFIDData
            Self.logger.info("RFID data - UDID: \(rfidData.uuid.hexEncodedString())")
            Self.logger.info("RFID data - Barcode: \(rfidData.barcode)")
            Self.logger.info("RFID data - Serial: \(rfidData.serial)")
            Self.logger.info("RFID data - Total labels: \(rfidData.totalLength)")
            Self.logger.info("RFID data - Used labels: \(rfidData.usedLength)")
            Self.logger.info("RFID data - Type: \(rfidData.type)")

            DispatchQueue.main.async {
                self.paperType.type = PaperType(rawValue: rfidData.barcode) ?? .unknown
                
                self.paperDetails.remainingCount = String(rfidData.totalLength - rfidData.usedLength)
                self.paperDetails.printedCount = String(rfidData.usedLength)
                self.paperDetails.barcode = rfidData.barcode
                self.paperDetails.serialNumber = rfidData.serial
                self.paperDetails.type = String(rfidData.type)
                self.printerDetails.isPaperInserted = true
            }
        }
        else if Notification.Name.App.noPaper ==  notification.name {
            Self.logger.info("No paper")
            DispatchQueue.main.async {
                self.printerDetails.isPaperInserted = false
            }
        }
        else if Notification.Name.App.startPrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("StartPrint \(value)")
        }
        else if Notification.Name.App.startPagePrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("StartPagePrint \(value)")
        }
        else if Notification.Name.App.endPrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("EndPrint \(value)")
        }
        else if Notification.Name.App.endPagePrint == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("EndPagePrint \(value)")
        }
        else if Notification.Name.App.setDimension == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("SetDimension \(value)")
        }
        else if Notification.Name.App.setLabelType == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("SetLabelType \(value)")
        }
        else if Notification.Name.App.setLabelDensity == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! Bool
            Self.logger.info("SetLabelDensity \(value)")
        }
        else if Notification.Name.App.getPrintStatus == notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! PrintStatus
            Self.logger.info("GetPrintStatus - Page: \(value.page)")
            Self.logger.info("GetPrintStatus - Progress 1: \(value.progress1)")
            Self.logger.info("GetPrintStatus - Progress 2: \(value.progress2)")
            
            notifyUI(name: .App.UI.printPrintingProgress,
                   userInfo: [String : Any](dictionaryLiteral: (Notification.Keys.value, value.progress1)))
            
            if value.progress2 == 100 {
                notify(name: .App.printFinished,
                       userInfo: [String : Any](dictionaryLiteral: (Notification.Keys.value, true)))
            }
        }
    }
    
    func connect() {
        do {
            if uplinkProcessor != nil {
                uplinkProcessor?.cancel()
            }
            try printerDevice?.open()
            printerDetails.name = printerDevice?.io.name ?? ""
            printerAvailability.isConnected = true
            Self.logger.info("Open")
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
    
    private func generateImage() -> ImageGenerator? {
        guard let image = ImageGenerator(paperType: paperType.type) else { return nil }
        for property in textProperties.properties {
            switch property.whatToPrint {
            case .text:
                guard !property.text.isEmpty else { continue }
                image.drawText(text: property.text,
                               fontName: property.fontDetails.name,
                               fontSize: property.fontDetails.size,
                               horizontal: property.horizontalAlignment.alignment,
                               vertical: property.verticalAlignment.alignment)
            case .qr:
                guard !property.text.isEmpty else { continue }
                image.generateQRCode(text: property.text,
                                     size: property.squareCodeSize,
                                     horizontal: property.horizontalAlignment.alignment,
                                     vertical: property.verticalAlignment.alignment)
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
                    image.drawBorder(divide_by: divider, doubleBorder: isDoubleFrame)
                    guard property.image.isEmpty else { continue }
                    guard let imagePreview = ImageGenerator(paperType: paperType.type) else { continue }
                    imagePreview.drawBorder(divide_by: divider, doubleBorder: isDoubleFrame)
                    DispatchQueue.main.async {
                        property.image = imagePreview.cgImage?.data ?? Data()
                    }
                }
            }
        }
        return image
    }
    
    private func generateImagePreview() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let preview = self.generateImage()?.image else { return }
            DispatchQueue.main.async {
                self.imagePreview.image = preview
            }
        }
    }
    
    private func preparePrintData() -> [[UInt8]] {
        guard let data = self.generateImage()?.printerData else { return [] }

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
        
    private func executePrintCommands() async {
        do {
            let data = preparePrintData()
            guard !data.isEmpty else { return }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
                self.printer?.setLabelDensity(density: 1)
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPrint) {
                self.printer?.startPrint()
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.startPagePrint) {
                self.printer?.startPagePrint()
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.setDimension) {
                self.printer?.setDimension(width: UInt16(self.paperType.type.printableSizeInPixels.width),
                                           height: UInt16(self.paperType.type.printableSizeInPixels.height))
            }
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.setLabelDensity) {
                self.printer?.setLabelDensity(density: 1)
            }
            
            let max = data.count
            var currentStep = 1
            for packet in data {
                printer?.setPrinterData(data: packet)
                notifyUI(name: .App.UI.printSendingProgress,
                         userInfo: [String : Any](dictionaryLiteral: (Notification.Keys.value, currentStep != max ? Double(currentStep) / Double(max) * 100.0 : 100.0)))
                currentStep += 1
                usleep(50000)
            }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPagePrint) {
                self.printer?.endPagePrint()
            }
            
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.printFinished, timeout: 10000000000) {
                while !Task.isCancelled {
                    self.printer?.getPrintStatus()
                    try await Task.sleep(nanoseconds: 50000000)
                }
            }
          
            try await SendAndWaitAsync.waitOnBoolResult(name: .App.endPrint) {
                self.printer?.endPrint()
            }
            
            printer?.getRFIDData()
        }
        catch {
            Self.logger.error("Something went wrong when printing")
            notifyUIAlert(alertType: .printError)
        }
    }
        
    private func printLabel() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            notifyUI(name: .App.UI.printStarted)
            Task {
                defer {
                    self.notifyUI(name: .App.UI.printDone)
                }
                await self.executePrintCommands()
            }
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
