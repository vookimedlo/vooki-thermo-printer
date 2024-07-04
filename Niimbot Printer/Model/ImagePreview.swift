//
//  ImagePreview.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 23.06.2024.
//

import Foundation
import AppKit

@Observable
class ImagePreview: ObservableObject, Notifier {
    var image: NSImage = NSImage(size: NSSize(width: PaperType.unknown.printableSizeInPixels.width,
                                              height: PaperType.unknown.printableSizeInPixels.height))
}
