//
//  NSNotifications.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

extension Notification.Name {
    public struct App {
        static public let startPopulatingPeripherals = NSNotification.Name("notify-bt-start-pop")
        static public let stopPopulatingPeripherals = NSNotification.Name("notify-bt-stop-pop")
        static public let selectedPeripheral = NSNotification.Name("notify-bt-selected")
        static public let lastSelectedPeripheral = NSNotification.Name("notify-bt-selected-last")
        static public let disconnectPeripheral = NSNotification.Name("notify-bt-disconnect")
        static public let bluetoothPeripheralDisconnected = NSNotification.Name("notify-bt-disconnected")
        static public let bluetoothPeripheralDiscovered = NSNotification.Name("notify-bt-perip")
        static public let printRequested = NSNotification.Name("notify-print-req")
        static public let textPropertiesUpdated = NSNotification.Name("notify-text-props-updated")

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
        static public let cancelPrint = NSNotification.Name("notify-cancel-print")
        static public let startPagePrint = NSNotification.Name("notify-start-page-print")
        static public let endPagePrint = NSNotification.Name("notify-end-page-print")
        static public let allowPrintClear = NSNotification.Name("notify-allow-print-clear")
        static public let setLabelType = NSNotification.Name("notify-set-label-type")
        static public let setLabelDensity = NSNotification.Name("notify-set-label-density")
        static public let setDimension = NSNotification.Name("notify-set-dimension")
        static public let getPrintStatus = NSNotification.Name("notify-get-print-status")
        static public let printerCheckLine = NSNotification.Name("notify-printer-check-line")

        static public let printFinished = NSNotification.Name("notify-print-finished")
        static public let printOpsTimedOut = NSNotification.Name("notify-print-ops-timeout")
        
        static public let paperChanged = NSNotification.Name("notify-paper-changed")
        static public let paperDetect = NSNotification.Name("notify-paper-detect")
        
        static public let loadHistoricalItem = NSNotification.Name("notify-load-historical-item")
        static public let deleteHistoricalItem = NSNotification.Name("notify-delete-historical-item")
        static public let deleteSavedItem = NSNotification.Name("notify-delete-saved-item")
        static public let historyRemoveAll = NSNotification.Name("notify-historical-item-remove-all")
        static public let historyKeepRecords = NSNotification.Name("notify-historical-item-keep")
        static public let historyRemoveOlderRecords = NSNotification.Name("notify-historical-item-remove-older")
        static public let showView = NSNotification.Name("notify-view-show")

        struct UI {
            static public let printSendingProgress = NSNotification.Name("notify-ui-print-send-progress")
            static public let printPrintingProgress = NSNotification.Name("notify-ui-print-progress")
            static public let printDone = NSNotification.Name("notify-ui-print-done")
            static public let printStarted = NSNotification.Name("notify-ui-print-start")
            static public let alert = NSNotification.Name("notify-ui-alert")
        }
    }
}

extension Notification {
    public class Keys {
        static public let packet = "key-packet"
        static public let value = "key-value"
        static public let peripheral = "key-peripheral"
    }
}
