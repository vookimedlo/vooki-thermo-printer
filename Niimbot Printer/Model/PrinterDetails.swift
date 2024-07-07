//
//  PrinterDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation

@Observable
class PrinterDetails: ObservableObject {
    var name = ""
    var serialNumber: String = ""
    var softwareVersion: String = ""
    var deviceType: String = ""
    var isPaperInserted: Bool = false
    var batteryLevel: Int = 0
    
    func clear() {
        name = ""
        serialNumber = ""
        softwareVersion = ""
        deviceType = ""
        isPaperInserted = false
        batteryLevel = 0
    }
}
