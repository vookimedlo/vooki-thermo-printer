//
//  ViewController.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 27.05.2024.
//

import Foundation
import Cocoa
import os

class ViewController: NSViewController, NotificationObservable, NSTextFieldDelegate, NSComboBoxDelegate {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ViewController.self)
    )
    
    @IBOutlet weak var fontComboBox: NSComboBox!
    @IBOutlet var fontArrayController: NSArrayController!
    
    @IBOutlet weak var fontSizeSlider: NSSlider!
    @IBOutlet weak var fontSizeStepper: NSStepper!
    @IBOutlet weak var fontSizeTextEdit: NSTextField!
    @IBOutlet weak var printTextEdit: NSTextField!
    
    @IBOutlet weak var deviceTypeLabel: NSTextFieldCell!
    @IBOutlet weak var batteryLevelLabel: NSTextFieldCell!
    @IBOutlet weak var batteryLevelIndicator: NSLevelIndicatorCell!
    @IBOutlet weak var hardwareVersionLabel: NSTextFieldCell!
    @IBOutlet weak var softwareVersionLabel: NSTextFieldCell!
    @IBOutlet weak var serialNumberLabel: NSTextField!
    
    
    @IBOutlet weak var paperInsertedLabel: NSTextField!
    @IBOutlet weak var remainingLabel: NSTextField!
    @IBOutlet weak var printedLabel: NSTextField!
    @IBOutlet weak var serialLabel: NSTextField!
    @IBOutlet weak var barcodeLabel: NSTextField!
    @IBOutlet weak var typeLabel: NSTextField!
    
    @IBOutlet weak var previewImageCell: NSImageCell!
    
    private var printer: Printer?
    private var printerDevice: PrinterDevice?
    private var uplinkProcessor: UplinkProcessor?
    
    private var printerLabel: NSImage?
    private var printerLabelData: [[UInt8]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontSizeStepper.target = self
        fontSizeStepper.action = #selector(onStepperChange(_:))
        fontSizeSlider.target = self
        fontSizeSlider.action = #selector(onSliderChange(_:))

        printTextEdit.delegate = self
        
        fontArrayController.content = NSFontManager.shared.availableFonts
        fontComboBox.reloadData()
        fontComboBox.selectItem(withObjectValue: "Chalkboard")
        
    
        registerNotification(name: Notification.Name.App.serialNumber,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.softwareVersion,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.hardwareVersion,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.batteryInformation,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.deviceType,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.rfidData,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.noPaper,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.startPrint,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.startPagePrint,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.endPrint,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.endPagePrint,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.setDimension,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.setLabelType,
                                   selector: #selector(receivePrinterNotification))
        registerNotification(name: Notification.Name.App.setLabelDensity,
                                   selector: #selector(receivePrinterNotification))
                
        printerDevice = PrinterDevice(io: BluetoothIO(bluetoothAccess: BluetoothSupport()))
        printer = Printer(printerDevice: self.printerDevice!)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func connectButtonPressed(_ sender: NSButton) {
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
    
    @IBAction func disconnectButtonPressed(_ sender: NSButton) {
        self.printerDevice?.close()
        self.uplinkProcessor?.stopProcessing()
    }
    
    
    @IBAction func sendButtonPressed(_ sender: NSButton) {
        printer?.getSerialNumber()
        printer?.getSoftwareVersion()
        printer?.getHardwareVersion()
        printer?.getBatteryInformation()
        printer?.getDeviceType()
        printer?.getRFIDData()
        printer?.getAutoShutdownTime()
        printer?.getDensity()
        printer?.getLabelType()

    }
    
    private func generatePrinterLabelData() {
        guard let image = ImageGenerator(size: CGSize(width: 240, height: 120)) else { return }
        image.drawText(text: printTextEdit.stringValue, fontName: fontComboBox.objectValueOfSelectedItem as! String, fontSize: Int(fontSizeTextEdit.intValue))
        (printerLabelData, printerLabel) = image.printerDataAndPreview
    }
    
    private func showPreview() {
        generatePrinterLabelData()
        previewImageCell.image = printerLabel
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let fontComboBox = notification.object as? NSComboBox, self.fontComboBox.identifier == fontComboBox.identifier {
            showPreview()
        }
    }
        
    public func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, self.printTextEdit.identifier == textField.identifier {
            showPreview()
        }
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveUp) || commandSelector == #selector(moveDown) {
            if control == fontSizeTextEdit {
                return fontSizeStepper.sendAction(commandSelector, to: fontSizeStepper) && fontSizeSlider.sendAction(commandSelector, to: fontSizeSlider)
            }
        }
        
        if control == printTextEdit {
            if commandSelector == #selector(insertNewline) {
                return true
            }
            if commandSelector == #selector(insertTab) || commandSelector == #selector(insertBacktab) {
                // TODO
                return false
            }
        }

        return false
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        printer?.setLabelDensity(density: 1)
        printer?.setLabelType(type: 1)
        printer?.startPrint()
        printer?.startPagePrint()
        printer?.setDimension(width: 240, height: 120)
        sleep(1)
        
        var rowNumber: UInt16 = 0
        for rowBytes in printerLabelData {
            let bitsPerByte = UInt8.bitWidth
            let remainingBitCount = rowBytes.count % bitsPerByte
            guard remainingBitCount == 0 else {
                Self.logger.error("Cannot be byte aligned -  remaining bit count: \(remainingBitCount)")
                return // TODO: throw
            }

            let bytesCount = UInt16(rowBytes.count / bitsPerByte)
            var resultingData: [UInt8] = rowNumber.bigEndian.bytes + [0, 0, 0, 1]
            var offsetInRow = 0
            
            for _ in 0 ..< bytesCount {
                let bitsString = rowBytes[offsetInRow + 0 ..< offsetInRow + bitsPerByte].decEncodedString()
                guard let byte = UInt8(bitsString, radix: 2) else { return } // TODO: throw
                resultingData.append(byte)
                offsetInRow += bitsPerByte
            }
            rowNumber += 1
            printer?.setPrinterData(data: resultingData)
        }
        
        sleep(3)
        printer?.endPagePrint()
        sleep(4)
        printer?.endPrint()
    }
    
    @objc func receivePrinterNotification(_ notification: Notification) {
        Self.logger.info("Notification \(notification.name.rawValue) received")
        if Notification.Name.App.serialNumber ==  notification.name {
            let serial_number = notification.userInfo?[Notification.Keys.value] as! String
            Self.logger.info("Serial number: \(serial_number)")
            DispatchQueue.main.async {
                self.serialNumberLabel.stringValue = serial_number
            }
        }
        else if Notification.Name.App.softwareVersion == notification.name {
            let software_version = notification.userInfo?[Notification.Keys.value] as! Float
            Self.logger.info("Software version: \(software_version)")
            DispatchQueue.main.async {
                self.softwareVersionLabel.stringValue = String(software_version)
            }
        }
        else if Notification.Name.App.hardwareVersion == notification.name {
            let hardware_version = notification.userInfo?[Notification.Keys.value] as! Float
            Self.logger.info("Hardware version: \(hardware_version)")
            DispatchQueue.main.async {
                self.hardwareVersionLabel.stringValue = String(hardware_version)
            }
        }
        else if Notification.Name.App.batteryInformation == notification.name {
            let battery_information = notification.userInfo?[Notification.Keys.value] as! UInt8
            Self.logger.info("Battery information: \(battery_information)")
            DispatchQueue.main.async {
                self.batteryLevelLabel.stringValue = String(battery_information)
                self.batteryLevelIndicator.integerValue = Int(battery_information)
            }
        }
        else if Notification.Name.App.deviceType == notification.name {
            let device_type = notification.userInfo?[Notification.Keys.value] as! UInt16
            Self.logger.info("Device type: \(device_type)")
            DispatchQueue.main.async {
                self.deviceTypeLabel.stringValue = String(device_type)
            }
        }
        else if Notification.Name.App.rfidData == notification.name {
            let rfidData = notification.userInfo?[Notification.Keys.value] as! RFIDData
            Self.logger.info("RFID data - UDID: \(rfidData.uuid.hexEncodedString())")
            Self.logger.info("RFID data - Barcode: \(rfidData.barcode)")
            Self.logger.info("RFID data - Serial: \(rfidData.serial)")
            Self.logger.info("RFID data - Total labels: \(rfidData.totalLength)")
            Self.logger.info("RFID data - Used labels: \(rfidData.usedLength)")
            Self.logger.info("RFID data - Type: \(rfidData.type)")

            DispatchQueue.main.async {
                self.paperInsertedLabel.stringValue = "Yes"

                self.remainingLabel.stringValue = String(rfidData.totalLength - rfidData.usedLength)
                self.printedLabel.stringValue = String(rfidData.usedLength)
                self.barcodeLabel.stringValue = rfidData.barcode
                self.serialLabel.stringValue = rfidData.serial
                self.typeLabel.stringValue = String(rfidData.type)
            }
        }
        else if Notification.Name.App.noPaper == notification.name {
            Self.logger.info("No paper")
            DispatchQueue.main.async {
                self.paperInsertedLabel.stringValue = "No"
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
    }
    
    @objc func onStepperChange(_ sender: NSStepper) {
        fontSizeTextEdit.stringValue = "\(sender.integerValue)"
        fontSizeSlider.intValue = Int32(sender.integerValue)
        showPreview()
    }
    
    @objc func onSliderChange(_ sender: NSSlider) {
        fontSizeTextEdit.stringValue = "\(sender.integerValue)"
        fontSizeStepper.intValue = Int32(sender.integerValue)
        showPreview()
    }
       
}
