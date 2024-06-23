//
//  PrinterAppD110.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import SwiftUI
import SwiftData
import os


@main
class testApp: App, NotificationObservable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ViewController.self)
    )
        
    private var printer: Printer?
    private var printerDevice: PrinterDevice?
    private var uplinkProcessor: UplinkProcessor?
    
    private var bluetoothSupport: BluetoothSupport
        
    required init() {
        bluetoothSupport = BluetoothSupport()
        
        for name in [Notification.Name.App.textToPrint,
                     Notification.Name.App.fontSelection] {
            registerNotification(name: name,
                                       selector: #selector(receiveNotification))
        }

        for name in [Notification.Name.App.startPopulatingPeripherals,
                     Notification.Name.App.stopPopulatingPeripherals,
                     Notification.Name.App.disconnectPeripheral,
                     Notification.Name.App.selectedPeripheral,
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
                     Notification.Name.App.setLabelDensity] {
            registerNotification(name: name,
                                       selector: #selector(receivePrinterNotification))
        }
        
        generatePrinterLabelData()
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
    @State private var fontDetails = FontDetails()
    @State private var textDetails = TextDetails()
    @State private var imagePreview = ImagePreview()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bluetoothPepripherals)
                .environmentObject(printerDetails)
                .environmentObject(paperDetails)
                .environmentObject(fontDetails)
                .environmentObject(textDetails)
                .environmentObject(imagePreview)
        }
        .modelContainer(sharedModelContainer)
    }
    
    @objc func receiveNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        
        if Notification.Name.App.textToPrint ==  notification.name {
            let value = notification.userInfo?[Notification.Keys.value] as! String
            Self.logger.info("Text to print \(value)")
            generatePrinterLabelData()
        }
        else if Notification.Name.App.fontSelection ==  notification.name {
            let font = notification.userInfo?[Notification.Keys.font] as! String
            let size = notification.userInfo?[Notification.Keys.size] as! Int
            Self.logger.info("Font selection \(font) @ \(size)")
            generatePrinterLabelData()
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
                self.printerDetails.deviceType = String(device_type)
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
                self.printerDetails.isPaperInserted = "Yes"
                self.paperDetails.remainingCount = String(rfidData.totalLength - rfidData.usedLength)
                self.paperDetails.printedCount = String(rfidData.usedLength)
                self.paperDetails.barcode = rfidData.barcode
                self.paperDetails.serialNumber = rfidData.serial
                self.paperDetails.type = String(rfidData.type)
            }
        }
        else if Notification.Name.App.noPaper ==  notification.name {
            Self.logger.info("No paper")
            DispatchQueue.main.async {
                self.printerDetails.isPaperInserted = "No"            }
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
    }
    
    func connect() {
        do {
            if uplinkProcessor != nil {
                uplinkProcessor?.cancel()
            }
            try printerDevice?.open()
            Self.logger.info("Open")
            self.uplinkProcessor = UplinkProcessor(printerDevice: self.printerDevice!)
            self.uplinkProcessor?.startProcessing()
            printer?.getBatteryInformation()
            printer?.getSerialNumber()
            printer?.getSoftwareVersion()
            printer?.getHardwareVersion()
            printer?.getDeviceType()
            printer?.getRFIDData()
        } catch IOError.open {
            Self.logger.error("Open failed")
        } catch {
            Self.logger.error("Open failed - unknown failure")
        }
    }
    
    private func generatePrinterLabelData() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = ImageGenerator(size: CGSize(width: 240, height: 120)) else { return }
            image.drawText(text: self.textDetails.text, fontName: self.fontDetails.name, fontSize: self.fontDetails.size)
            guard let preview = image.image else { return }
            DispatchQueue.main.async {
                self.imagePreview.image = preview
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
