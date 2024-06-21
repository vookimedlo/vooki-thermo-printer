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

        
        registerNotification(name: Notifications.Names.startPopulatingPeripherals,
                                   selector: #selector(receiveBluetoothNotification))
        registerNotification(name: Notifications.Names.stopPopulatingPeripherals,
                                   selector: #selector(receiveBluetoothNotification))
        registerNotification(name: Notifications.Names.selectedPeripheral,
                                   selector: #selector(receiveBluetoothNotification))
        
        registerNotification(name: Notifications.Names.disconnectPeripheral,
                                   selector: #selector(receiveBluetoothNotification))
        registerNotification(name: Notifications.Names.bluetoothPeripheralDiscovered,
                                   selector: #selector(receiveBluetoothNotification))
        registerNotification(name: Notifications.Names.serialNumber,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.softwareVersion,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.hardwareVersion,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.batteryInformation,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.deviceType,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.rfidData,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.noPaper,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.startPrint,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.startPagePrint,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.endPrint,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.endPagePrint,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.setDimension,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.setLabelType,
                                   selector: #selector(receiveNotification))
        registerNotification(name: Notifications.Names.setLabelDensity,
                                   selector: #selector(receiveNotification))
        
        
//        DispatchQueue.global(qos: .userInitiated).async { [self] in
//            sleep(5)
//            printerDevice = PrinterDevice(io: BluetoothIO(bluetoothAccess: BluetoothSupport()))
//            printer = Printer(printerDevice: self.printerDevice!)
//        }

        
//        DispatchQueue.global(qos: .userInitiated).async { [self] in
//            sleep(5)
//            do {
//                if uplinkProcessor != nil {
//                    uplinkProcessor?.cancel()
//                }
//                try printerDevice?.open()
//                Self.logger.info("Open")
//                self.uplinkProcessor = UplinkProcessor(printerDevice: self.printerDevice!)
//                self.uplinkProcessor?.startProcessing()
//                
//            } catch IOError.open {
//                Self.logger.error("Open failed")
//            } catch {
//                Self.logger.error("Open failed - unknown failure")
//            }
//            printer?.getSerialNumber()
//            printer?.getSoftwareVersion()
//            printer?.getHardwareVersion()
//            printer?.getBatteryInformation()
//            printer?.getDeviceType()
//            printer?.getRFIDData()
//            printer?.getAutoShutdownTime()
//            printer?.getDensity()
//            printer?.getLabelType()
//        }
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

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bluetoothPepripherals)
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
                //self.serialNumberLabel.stringValue = serial_number
            }
        }
        else if Notifications.Names.softwareVersion ==  notification.name {
            let software_version = notification.userInfo?[Notifications.Keys.value] as! Float
            Self.logger.info("Software version: \(software_version)")
            DispatchQueue.main.async {
                //self.softwareVersionLabel.stringValue = String(software_version)
            }
        }
        else if Notifications.Names.hardwareVersion ==  notification.name {
            let hardware_version = notification.userInfo?[Notifications.Keys.value] as! Float
            Self.logger.info("Hardware version: \(hardware_version)")
            DispatchQueue.main.async {
                //self.hardwareVersionLabel.stringValue = String(hardware_version)
            }
        }
        else if Notifications.Names.batteryInformation ==  notification.name {
            let battery_information = notification.userInfo?[Notifications.Keys.value] as! UInt8
            Self.logger.info("Battery information: \(battery_information)")
            DispatchQueue.main.async {
                //self.batteryLevelLabel.stringValue = String(battery_information)
                //self.batteryLevelIndicator.integerValue = Int(battery_information)
            }
        }
        else if Notifications.Names.deviceType ==  notification.name {
            let device_type = notification.userInfo?[Notifications.Keys.value] as! UInt16
            Self.logger.info("Device type: \(device_type)")
            DispatchQueue.main.async {
                //self.deviceTypeLabel.stringValue = String(device_type)
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
//                self.paperInsertedLabel.stringValue = "Yes"
//
//                self.remainingLabel.stringValue = String(rfidData.totalLength - rfidData.usedLength)
//                self.printedLabel.stringValue = String(rfidData.usedLength)
//                self.barcodeLabel.stringValue = rfidData.barcode
//                self.serialLabel.stringValue = rfidData.serial
//                self.typeLabel.stringValue = String(rfidData.type)
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
