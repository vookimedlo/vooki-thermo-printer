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

        for name in [Notifications.Names.startPopulatingPeripherals,
                     Notifications.Names.stopPopulatingPeripherals,
                     Notifications.Names.disconnectPeripheral,
                     Notifications.Names.bluetoothPeripheralDiscovered] {
            registerNotification(name: name,
                                       selector: #selector(receiveBluetoothNotification))
        }
        
        for name in [Notifications.Names.serialNumber,
                     Notifications.Names.softwareVersion,
                     Notifications.Names.hardwareVersion,
                     Notifications.Names.batteryInformation,
                     Notifications.Names.deviceType,
                     Notifications.Names.rfidData,
                     Notifications.Names.noPaper,
                     Notifications.Names.startPrint,
                     Notifications.Names.startPagePrint,
                     Notifications.Names.endPrint,
                     Notifications.Names.endPagePrint,
                     Notifications.Names.setDimension,
                     Notifications.Names.setLabelType,
                     Notifications.Names.setLabelDensity] {
            registerNotification(name: name,
                                       selector: #selector(receiveNotification))
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


    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bluetoothPepripherals)
                .environmentObject(printerDetails)
                .environmentObject(paperDetails)
        }
        .modelContainer(sharedModelContainer)
    }
    
    @objc func receiveBluetoothNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")

        if Notifications.Names.bluetoothPeripheralDiscovered ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.peripheral] as! BluetoothPeripheral
            Self.logger.info("Bluetooth peripheral \(value.identifier)")
            DispatchQueue.main.async {
                self.bluetoothPepripherals.add(peripheral: value)
            }
        }
        else if Notifications.Names.disconnectPeripheral ==  notification.name {
            Self.logger.info("Disconnecting peripheral")
            printerDevice?.close()
            uplinkProcessor?.stopProcessing()
        }
        else if Notifications.Names.startPopulatingPeripherals == notification.name {
            Self.logger.info("Populating peripherals")
            bluetoothSupport.startScanning()
        }
        else if Notifications.Names.stopPopulatingPeripherals == notification.name {
            Self.logger.info("Stop populating peripherals")
            bluetoothSupport.stopScanning()
        }
        else if Notifications.Names.selectedPeripheral == notification.name {
            let uuid = notification.userInfo?[Notifications.Keys.value] as! UUID
            Self.logger.info("Selected peripheral \(uuid.uuidString)")
            guard let peripheral = bluetoothPepripherals.find(identifier: uuid)?.peripheral else { return }
            printerDevice = PrinterDevice(io: BluetoothIO(bluetoothAccess: BluetoothSupport(peripheral: peripheral)))
            printer = Printer(printerDevice: printerDevice!)
            connect()
        }
    }

    @objc func receiveNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        
        if Notifications.Names.serialNumber ==  notification.name {
            let serial_number = notification.userInfo?[Notifications.Keys.value] as! String
            Self.logger.info("Serial number: \(serial_number)")
            DispatchQueue.main.async {
                self.printerDetails.serialNumber = serial_number
            }
        }
        else if Notifications.Names.softwareVersion ==  notification.name {
            let software_version = notification.userInfo?[Notifications.Keys.value] as! Float
            Self.logger.info("Software version: \(software_version)")
            DispatchQueue.main.async {
                self.printerDetails.softwareVersion = String(software_version)
            }
        }
        else if Notifications.Names.hardwareVersion ==  notification.name {
            let hardware_version = notification.userInfo?[Notifications.Keys.value] as! Float
            Self.logger.info("Hardware version: \(hardware_version)")
        }
        else if Notifications.Names.batteryInformation ==  notification.name {
            let battery_information = notification.userInfo?[Notifications.Keys.value] as! UInt8
            Self.logger.info("Battery information: \(battery_information)")
            DispatchQueue.main.async {
                self.printerDetails.batteryLevel = Int(battery_information)
            }
        }
        else if Notifications.Names.deviceType ==  notification.name {
            let device_type = notification.userInfo?[Notifications.Keys.value] as! UInt16
            Self.logger.info("Device type: \(device_type)")
            DispatchQueue.main.async {
                self.printerDetails.deviceType = String(device_type)
            }
        }
        else if Notifications.Names.rfidData ==  notification.name {
            let rfidData = notification.userInfo?[Notifications.Keys.value] as! RFIDData
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
        else if Notifications.Names.noPaper ==  notification.name {
            Self.logger.info("No paper")
            DispatchQueue.main.async {
//                self.paperInsertedLabel.stringValue = "No"
            }
        }
        else if Notifications.Names.startPrint ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
            Self.logger.info("StartPrint \(value)")
        }
        else if Notifications.Names.startPagePrint ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
            Self.logger.info("StartPagePrint \(value)")
        }
        else if Notifications.Names.endPrint ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
            Self.logger.info("EndPrint \(value)")
        }
        else if Notifications.Names.endPagePrint ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
            Self.logger.info("EndPagePrint \(value)")
        }
        else if Notifications.Names.setDimension ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
            Self.logger.info("SetDimension \(value)")
        }
        else if Notifications.Names.setLabelType ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
            Self.logger.info("SetLabelType \(value)")
        }
        else if Notifications.Names.setLabelDensity ==  notification.name {
            let value = notification.userInfo?[Notifications.Keys.value] as! Bool
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
}

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
