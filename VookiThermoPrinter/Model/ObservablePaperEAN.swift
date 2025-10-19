//
//  ObservablePaperEAN.swift
//  VookiThermoPrinter
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation

@MainActor
@Observable
final class ObservablePaperEAN: ObservableObject {
    var ean: PaperEAN = PaperEAN.unknown
}
