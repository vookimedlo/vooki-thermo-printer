//
//  ImagePreview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation
import AppKit

@MainActor
@Observable
class ImagePreview: ObservableObject, Notifier {
    var image: CGImage?
}
