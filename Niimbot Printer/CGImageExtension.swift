//
//  CGImageExtension.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 09.06.2024.
//

import Foundation
import AppKit

public extension CGImage {
    func rotatedContext(to orientation: CGImagePropertyOrientation) -> CGContext? {
        guard let colorSpace = self.colorSpace else { return nil }
                
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
        
        guard let context = CGContext(data: nil,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: self.bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: self.bitmapInfo.rawValue) else { return nil }
        
        context.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
        
        if mirrored { context.scaleBy(x: -1.0, y: 1.0) }
        
        context.rotate(by: radians)
        
        if swapWidthHeight {
            context.translateBy(x: -height / 2.0, y: -width / 2.0)
        } else {
            context.translateBy(x: -width / 2.0, y: -height / 2.0)
        }
        
        context.draw(self, in: CGRect(x: 0.0, y: 0.0, width: originalWidth, height: originalHeight))
        
        return context
    }
        
    func rotate(to orientation: CGImagePropertyOrientation) -> CGImage? {
        if orientation == .up { return self }
        return rotatedContext(to: orientation)?.makeImage()
    }
    
    func copyContext() -> CGContext? {
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil,
                                      width: self.width,
                                      height: self.height,
                                      bitsPerComponent: self.bitsPerComponent,
                                      bytesPerRow: self.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: self.bitmapInfo.rawValue) else { return nil }
        context.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        return context
    }
}
