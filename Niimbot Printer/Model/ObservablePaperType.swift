//
//  ObservablePaperType.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation

@MainActor
@Observable
final class ObservablePaperType: ObservableObject {
    var type: PaperType = PaperType.unknown
}
