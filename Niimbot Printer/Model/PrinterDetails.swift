//
//  PrinterDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation

@Observable
class PrinterDetails: ObservableObject {
    var serialNumber: String = "N/A"
    var softwareVersion: String = "N/A"
    var deviceType: String = "N/A"
    var isPaperInserted: String = "No"
    var batteryLevel: Int = 0
    
    func clear() {
        serialNumber = "N/A"
        softwareVersion = "N/A"
        deviceType = "N/A"
        isPaperInserted = "No"
        batteryLevel = 0
    }
}
