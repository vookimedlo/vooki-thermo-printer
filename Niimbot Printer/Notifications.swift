//
//  NSNotifications.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 01.06.2024.
//

import Foundation

class Notifications {
    class Names {
        static public let uplinkedPacket = NSNotification.Name("notify-uplinked-packet")
        static public let serialNumber = NSNotification.Name("notify-serial-number")
        static public let softwareVersion = NSNotification.Name("notify-software-version")
        static public let hardwareVersion = NSNotification.Name("notify-hardware-version")
        static public let batteryInformation = NSNotification.Name("notify-battery-information")
        static public let deviceType = NSNotification.Name("notify-device-type")
        static public let rfidData = NSNotification.Name("notify-rfid-data")
        static public let noPaper = NSNotification.Name("notify-no-paper")
    }
    
    class Keys {
        static public let packet = "key-packet"
        static public let value = "key-value"
    }
}
