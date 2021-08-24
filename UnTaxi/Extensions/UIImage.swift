//
//  UIImage.swift
//  Conaitor
//
//  Created by Donelkys Santana on 12/18/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

extension UIImage {
  func imageWithColor(color1: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    color1.setFill()
    
    let context = UIGraphicsGetCurrentContext()
    context?.translateBy(x: 0, y: self.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    context?.setBlendMode(CGBlendMode.normal)
    
    let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
    context?.clip(to: rect, mask: self.cgImage!)
    context?.fill(rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func saveImageToFile(name: String) -> URL{
    let filemgr = FileManager.default
    
    //let dirPaths = filemgr.urls(for: .documentDirectory,in: .userDomainMask)
    
    //let fileURL = dirPaths[0].appendingPathComponent(self.description)
    let filePath = URL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/\(name).jpg")
    
    if let renderedJPEGData =
        self.jpegData(compressionQuality: 0.5) {
      try! renderedJPEGData.write(to: filePath)
    }
    
    return filePath
  }
  
  func fixedOrientation() -> UIImage? {
    guard imageOrientation != UIImage.Orientation.up else {
      // This is default orientation, don't need to do anything
      return self.copy() as? UIImage
    }
    
    guard let cgImage = self.cgImage else {
      // CGImage is not available
      return nil
    }
    
    guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
      return nil // Not able to create CGContext
    }
    
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    switch imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: size.width, y: size.height)
      transform = transform.rotated(by: CGFloat.pi)
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.rotated(by: CGFloat.pi / 2.0)
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: size.height)
      transform = transform.rotated(by: CGFloat.pi / -2.0)
    case .up, .upMirrored:
      break
    @unknown default:
      break
    }
    
    // Flip image one more time if needed to, this is to prevent flipped image
    switch imageOrientation {
    case .upMirrored, .downMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
      transform = transform.translatedBy(x: size.height, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .up, .down, .left, .right:
      break
    @unknown default:
      break
    }
    
    ctx.concatenate(transform)
    
    switch imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      break
    }
    
    guard let newCGImage = ctx.makeImage() else { return nil }
    return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
  }
  
  func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(CGRect(x: 0, y: size.height - lineWidth, width: size.width, height: lineWidth))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
  
  func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
    // Determine the scale factor that preserves aspect ratio
    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height
    
    let scaleFactor = min(widthRatio, heightRatio)
    
    // Compute the new image size that preserves aspect ratio
    let scaledImageSize = CGSize(
      width: size.width * scaleFactor,
      height: size.height * scaleFactor
    )
    
    // Draw and return the resized UIImage
    let renderer = UIGraphicsImageRenderer(
      size: scaledImageSize
    )
    
    let scaledImage = renderer.image { _ in
      self.draw(in: CGRect(
        origin: .zero,
        size: scaledImageSize
      ))
    }
    
    return scaledImage
  }
  
  func addBorder(radius: Int, color: UIColor)->UIImage?{
    let square = CGSize(width: size.width, height: size.height)
    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
    imageView.contentMode = .center
    imageView.image = self
    imageView.layer.cornerRadius = CGFloat(radius)
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 1
    imageView.layer.borderColor = color.cgColor
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    imageView.layer.render(in: context)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result
  }
}
