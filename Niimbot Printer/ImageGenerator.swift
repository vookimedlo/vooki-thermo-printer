//
//  ImageGenerator.swift
//  Niimbot Printer
//
//  Created by Michal Duda on 06.06.2024.
//

import Foundation
import AppKit
import CoreGraphics
import CoreImage
import CoreText


class ImageGenerator {
    private var context: CGContext!
    
    public var image: NSImage? {
        guard Self.toBlackAndWhite(context: context, inverted: false) else { return nil }
        guard let image = context.makeImage() else { return nil }
        return NSImage(cgImage: image, size: .zero)
    }
    
    public var rotatedImage: NSImage? {
        return generateRotatedImage(inverted: false)
    }
    
    public var rotatedImageInverted: NSImage? {
        return generateRotatedImage(inverted: true)
    }
    
    public var printerData: [[UInt8]] {
        guard let image = context.makeImage() else { return [] }
        guard let rotatedImageContext = image.rotatedContext(to: .right) else { return [] }
        guard Self.toBlackAndWhite(context: rotatedImageContext, inverted: true) else { return [] }
        return Self.toBytes(context: rotatedImageContext)
    }
    
    private let margin: Margin

    public init? (size: CGSize) {
        margin = Margin(left: 0, right: 0, up: 0, bottom: 0)
        guard let ctx = createContext(size: size) else { return nil }
        context = ctx
    }
    
    public init? (paperType: PaperType) {
        margin = paperType.margin
        guard let ctx = createContext(size: paperType.printableSizeInPixels) else { return nil }
        context = ctx
    }

    private func createContext(size: CGSize) -> CGContext? {
        let width = Int(size.width)
        let height = Int(size.height)
        let bitmapBytesPerRow = width * 4
        let bufferLength = size.width * size.height * 4
        let bitmapData: CFMutableData = CFDataCreateMutable(nil, 0)
        CFDataSetLength(bitmapData, CFIndex(bufferLength))
        let bitmap = CFDataGetMutableBytePtr(bitmapData)
        let context = CGContext(data: bitmap,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bitmapBytesPerRow,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).rawValue)

        context?.saveGState()
        
        context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context?.fill(CGRectMake(0, 0, size.width, size.height))
        
        context?.restoreGState()
        
        return context
    }
    
    public func drawText(text: String, fontName: String, fontSize: Int, horizontal: AlignmentView.HorizontalAlignment, vertical: AlignmentView.VerticalAlignment) {
        context.saveGState()
        
        let color = CGColor.black
        let font = CTFontCreateWithName(fontName as CFString, CGFloat(fontSize), nil)
        
        let attributes: [NSAttributedString.Key : Any] = [.font: font, .foregroundColor: color]
        
        let attributedString = NSAttributedString(string: text,
                                                  attributes: attributes)
        
        let line = CTLineCreateWithAttributedString(attributedString)
        let stringRect = CGRectStandardize(CTLineGetImageBounds(line, context))
        
        let x: CGFloat = {
            switch horizontal {
            case .left:
                return margin.left
            case .center:
                return max((CGFloat(context.width) - stringRect.width) / 2.0, 0)
            case .right:
                return CGFloat(context.width) - stringRect.width - margin.right
            }
        }()
        
        let y: CGFloat = {
            switch vertical {
            case .bottom:
                return margin.bottom
            case .center:
                return max((CGFloat(context.height) - stringRect.height) / 2.0, 0)
            case .top:
                return CGFloat(context.height) - stringRect.height - margin.up
            }
        }()
        
        context.textPosition = CGPoint(x: x - stringRect.origin.x,
                                       y: y - stringRect.origin.y)
        
        CTLineDraw(line, context)
        
        context.setStrokeColor(CGColor.black)
        context.setLineWidth(1)
        
        #if DEBUG_CALIBRATION_PATTERN
        for i in 0..<50 {
            let offset = Double(i) * 10.0
            context.addRect(CGRect(x: 0 + offset,
                                   y: 0 + offset,
                                   width: stringRect.width - offset,
                                   height: stringRect.height - offset))
            context.drawPath(using: .stroke)
        }
        #endif

        #if DEBUG_BOUNDING_BOX
        context.setStrokeColor(CGColor.black)
        context.setLineWidth(1)
        context.addRect(CGRect(x: x,
                               y: y,
                               width: stringRect.width,
                               height: stringRect.height))
        context.drawPath(using: .stroke)
        #endif

        context.restoreGState()
    }
    
    private static func toBlackAndWhite(context: CGContext, inverted: Bool = false) -> Bool {
        guard let data = context.data else { return false }
        let width = context.width
        let height = context.height
        let pixelBuffer = data.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for offset in 0 ..< height * width {
            if inverted ? !pixelBuffer[offset].isWhite() : pixelBuffer[offset].isWhite() {
                pixelBuffer[offset] = RGBA32.white
            } else {
                pixelBuffer[offset] = RGBA32.black
            }
        }
        return true
    }
    
    private static func toBytes(context: CGContext) -> [[UInt8]] {
        guard let data = context.data else { return [] }
        let width = context.width
        let height = context.height
        let pixelBuffer = data.bindMemory(to: RGBA32.self, capacity: width * height)

        var result: [[UInt8]] = Array<[UInt8]>(repeating: Array<UInt8>(repeating: 0,
                                                                       count: width),
                                               count: height)

        for x in 0 ..< height {
            for y in 0 ..< width {
                let offset = x * width + y
                result[x][y] = pixelBuffer[offset].isWhite() ? 1 : 0
            }
        }
        return result
    }

    public func writeToPNG(url: URL) throws {
        guard let image = context.makeImage() else { throw NSError() }
        let cicontext = CIContext()
        let ciimage = CIImage(cgImage: image)
        try cicontext.writePNGRepresentation(of: ciimage, to: url, format: .RGBA8, colorSpace: ciimage.colorSpace!)
    }
    
    private func generateRotatedImage(inverted: Bool = false) -> NSImage? {
        guard let image = context.makeImage() else { return nil }
        guard let rotatedImageContext = image.rotatedContext(to: .right) else { return nil }
        guard Self.toBlackAndWhite(context: rotatedImageContext, inverted: inverted) else { return nil }
        guard let rotatedImage = rotatedImageContext.makeImage() else { return nil }

        return NSImage(cgImage: rotatedImage, size: .zero)
    }
    
    struct RGBA32: Equatable {
        private var color: UInt32
        
        private init(color: UInt32) {
            self.color = color
        }

        var red: UInt8 {
            return UInt8((color >> 24) & 0xFF)
        }

        var green: UInt8 {
            return UInt8((color >> 16) & 0xFF)
        }

        var blue: UInt8 {
            return UInt8((color >> 8) & 0xFF)
        }
        
        func isWhite() -> Bool {
            return red == 0xFF && green == 0xFF && blue == 0xFF
        }
        
        static let black = RGBA32(color: 0xFF000000)
        static let white = RGBA32(color: 0xFFFFFFFF)
    }
}
