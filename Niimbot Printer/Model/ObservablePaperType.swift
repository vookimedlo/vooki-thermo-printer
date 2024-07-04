//
//  ObservablePaperType.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 04.07.2024.
//

import Foundation

@Observable
class ObservablePaperType: ObservableObject {
    var type: PaperType = PaperType.unknown
}
