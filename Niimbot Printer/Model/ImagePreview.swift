//
//  ImagePreview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation
import CoreGraphics

@MainActor
@Observable
final class ImagePreview: ObservableObject, Notifiable {
    var image: CGImage?
}
