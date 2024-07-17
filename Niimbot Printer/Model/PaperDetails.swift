//
//  PaperDetails.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation

@MainActor
@Observable
final class PaperDetails: ObservableObject {
    var serialNumber: String = "N/A"
    var remainingCount: String = "N/A"
    var printedCount: String = "N/A"
    var barcode: String = "N/A"
    var type: String = "N/A"
    
    func clear() {
        serialNumber = ""
        remainingCount = ""
        printedCount = ""
        barcode = ""
        type = ""
    }
}
