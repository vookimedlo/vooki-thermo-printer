//
//  Image.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.06.2024.
//

import Foundation
import CoreGraphics
import CoreText

import CoreImage
import AppKit

import ImageIO


class Image {
    var context: CGContext?
    
    var image: NSImage? {
        guard let context = self.context else { return nil }
        guard let image = context.makeImage() else { return nil }
        return NSImage(cgImage: image, size: .zero)
    }
    
    public init (size: CGSize) {
        context = createContext(size: size)
    }
        
    private func createContext(size: CGSize) -> CGContext? {
        let pixelsWide = Int(size.width)
        let pixelsHigh = Int(size.height)
        let bitmapBytesPerRow = pixelsWide * 4
        
        let bufferLength = Int(size.width * size.height * 4)
        
        let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
        CFDataSetLength(bitmapData, CFIndex(bufferLength))
        let bitmap = CFDataGetMutableBytePtr(bitmapData)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: bitmap,
                                width: pixelsWide,
                                height: pixelsHigh,
                                bitsPerComponent: 8,
                                bytesPerRow: bitmapBytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
        
        context?.saveGState()

        
        context?.setFillColor (red: 1, green: 1, blue: 1, alpha: 1)
        context?.fill(CGRectMake (0, 0, size.width, size.height ))
        
        context?.restoreGState()
        
        return context
    }
    
    public func drawText(text: String, fontSize: Int) {
        guard let context = self.context else { return }
        
        context.saveGState()
    
        let margin: CGFloat = 10
        let color = CGColor.black
        let fontName = "Chalkboard" as CFString
        let font = CTFontCreateWithName(fontName, CGFloat(fontSize), nil)

        let attributes: [NSAttributedString.Key : Any] = [.font: font, .foregroundColor: color]

        let attributedString = NSAttributedString(string: text,
                                                  attributes: attributes)

        let line = CTLineCreateWithAttributedString(attributedString)
        let stringRect = CTLineGetImageBounds(line, context)
        
        let ctxHeightHalf = CGFloat(context.height) / 2
        let fntHeightHalf = stringRect.height / 2
        
        context.textPosition = CGPoint(x: margin,
                                       y: max(ctxHeightHalf - fntHeightHalf, 0))

        CTLineDraw(line, context)

        context.restoreGState()
    }
    
    public func writeToPNG(url: URL) throws {
        guard let image = context?.makeImage() else { throw NSError() }
        let cicontext = CIContext()
        let ciimage = CIImage(cgImage: image)
        try cicontext.writePNGRepresentation(of: ciimage, to: url, format: .RGBA8, colorSpace: ciimage.colorSpace!)
    }
}
