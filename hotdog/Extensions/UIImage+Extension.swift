//
//  UIImage+Extension.swift
//  hotdog
//
//  Created by Ali Can Batur on 08/06/2017.
//  Copyright © 2017 alikoo. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    // http://swiftexample.info/snippet/swift/imagetopixelbufferswift_omarojo_swift
    // big thanks to omarojo!!
    func resize(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func asPixelBuffer() -> CVPixelBuffer? {
        //Reference: https://github.com/cieslak/CoreMLCrap/blob/master/MachineLearning/ViewController.swift#L42
        var pixelBuffer : CVPixelBuffer?
        let imageDimension : CGFloat = 224.0
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let imageSize = CGSize(width:imageDimension, height:imageDimension)
        let imageRect = CGRect(origin: CGPoint(x:0, y:0), size: imageSize)
        
        let options = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                       kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0)
        draw(in:imageRect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(newImage.size.width),
                                         Int(newImage.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         options,
                                         &pixelBuffer)
        guard (status == kCVReturnSuccess),
            let uwPixelBuffer = pixelBuffer else {
                return nil
        }
        
        CVPixelBufferLockBaseAddress(uwPixelBuffer,
                                     CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(uwPixelBuffer)
        let context = CGContext(data: pixelData,
                                width: Int(newImage.size.width),
                                height: Int(newImage.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(uwPixelBuffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        guard let uwContext = context else {
            return nil
        }
        
        uwContext.translateBy(x: 0, y: newImage.size.height)
        uwContext.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(uwContext)
        newImage.draw(in: CGRect(x: 0,
                                 y: 0,
                                 width: newImage.size.width,
                                 height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(uwPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
}
