//
//  AppDetails.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 18.10.2025.
//

protocol AppDetails: Sendable {
    var dpi: PaperEAN.DPI { get }
    var printerVariant: String { get }
    var peripheralFilter: String { get }
}

struct DefaultAppDetails: AppDetails {
    let dpi: PaperEAN.DPI
    let printerVariant: String
    let peripheralFilter: String
    
    static var defaultValue: AppDetails {
        DefaultAppDetails(
            dpi: .dpi300,
            printerVariant: "GenericPrinter",
            peripheralFilter: ""
        )
    }
}
