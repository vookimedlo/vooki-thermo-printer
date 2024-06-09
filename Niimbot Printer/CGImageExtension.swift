//
//  CGImageExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 09.06.2024.
//

import Foundation
import AppKit

public extension CGImage {
    func rotate(to orientation: CGImagePropertyOrientation) -> CGImage? {
        guard let colorSpace = self.colorSpace else { return nil }
        
        if orientation == .up { return self }
        
        let (radians, swapWidthHeight, mirrored) = { () -> (Double, Bool, Bool) in
            switch orientation {
            case .up:
                return (0.0, false, false)
            case .upMirrored:
                return (0.0, false, true)
            case .right:
                return (Double.pi / -2, true, false)
            case .rightMirrored:
                return (Double.pi / -2, true, true)
            case .down:
                return (Double.pi, false, false)
            case .downMirrored:
                return (Double.pi, false, true)
            case .left:
                return (Double.pi / 2, true, false)
            case .leftMirrored:
                return (Double.pi / 2, true, false)
            }
        }()
             
        let originalWidth: CGFloat = CGFloat(self.width)
        let originalHeight: CGFloat = CGFloat(self.height)
        
        let width: CGFloat = swapWidthHeight ? originalHeight : originalWidth
        let height: CGFloat = swapWidthHeight ? originalWidth : originalHeight
                
        let bytesPerRow = (Int(width) * bitsPerPixel) / 8
        
        guard let contextRef = CGContext(data: nil,
                                         width: Int(width),
                                         height: Int(height),
                                         bitsPerComponent: self.bitsPerComponent,
                                         bytesPerRow: bytesPerRow,
                                         space: colorSpace,
                                         bitmapInfo: self.bitmapInfo.rawValue) else { return nil }
        
        contextRef.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
        
        if mirrored { contextRef.scaleBy(x: -1.0, y: 1.0) }
        
        contextRef.rotate(by: radians)
        
        if swapWidthHeight {
            contextRef.translateBy(x: -height / 2.0, y: -width / 2.0)
        } else {
            contextRef.translateBy(x: -width / 2.0, y: -height / 2.0)
        }
        
        contextRef.draw(self, in: CGRect(x: 0.0, y: 0.0, width: originalWidth, height: originalHeight))
                
        return contextRef.makeImage()
    }
}
