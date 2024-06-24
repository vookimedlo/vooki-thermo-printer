//
//  NSNotifications.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

extension Notification.Name {
    struct App {
        static public let startPopulatingPeripherals = NSNotification.Name("notify-bt-start-pop")
        static public let stopPopulatingPeripherals = NSNotification.Name("notify-bt-stop-pop")
        static public let selectedPeripheral = NSNotification.Name("notify-bt-selected")
        static public let disconnectPeripheral = NSNotification.Name("notify-bt-disconnect")
        static public let bluetoothPeripheralDiscovered = NSNotification.Name("notify-bt-perip")
        
        static public let textToPrint = NSNotification.Name("notify-text-print")
        static public let fontSelection = NSNotification.Name("notify-font-selection")
        static public let printRequested = NSNotification.Name("notify-print-req")


        static public let uplinkedPacket = NSNotification.Name("notify-uplinked-packet")
        static public let density = NSNotification.Name("notify-density")
        static public let labelType = NSNotification.Name("notify-label-type")
        static public let autoShutdownTime = NSNotification.Name("notify-auto-shutdown-time")
        static public let serialNumber = NSNotification.Name("notify-serial-number")
        static public let softwareVersion = NSNotification.Name("notify-software-version")
        static public let hardwareVersion = NSNotification.Name("notify-hardware-version")
        static public let batteryInformation = NSNotification.Name("notify-battery-information")
        static public let deviceType = NSNotification.Name("notify-device-type")
        static public let rfidData = NSNotification.Name("notify-rfid-data")
        static public let noPaper = NSNotification.Name("notify-no-paper")
        static public let startPrint = NSNotification.Name("notify-start-print")
        static public let endPrint = NSNotification.Name("notify-end-print")
        static public let startPagePrint = NSNotification.Name("notify-start-page-print")
        static public let endPagePrint = NSNotification.Name("notify-end-page-print")
        static public let allowPrintClear = NSNotification.Name("notify-allow-print-clear")
        static public let setLabelType = NSNotification.Name("notify-set-label-type")
        static public let setLabelDensity = NSNotification.Name("notify-set-label-density")
        static public let setDimension = NSNotification.Name("notify-set-dimension")
    }
}

extension Notification {
    class Keys {
        static public let packet = "key-packet"
        static public let value = "key-value"
        static public let peripheral = "key-peripheral"
        static public let font = "key-font"
        static public let size = "key-size"
    }
}
