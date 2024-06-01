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
    }
    
    class Keys {
        static public let packet = "key-packet"
    }
}
