//
//  ImagePickerProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 08.02.25.
// 
import Foundation
import SwiftUI 
import PhotosUI

@MainActor
protocol ImagePickerProtocol: ObservableObject {
    var image: Image? { get set }
    var uiImage: UIImage? { get set }
    var fileName: String { get set }
}

extension ImagePickerProtocol {
    func setImage(item: PhotosPickerItem) {
        Task {
            if let imageData = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: imageData) {
                if uiImage.size.height > uiImage.size.width {
                    let scaledImage = uiImage.scaleToHeight(400)
                    self.uiImage = scaledImage
                    self.image = Image(uiImage: scaledImage)
                } else {
                    let scaledImage = uiImage.scaleToHeight(400)
                    self.uiImage = scaledImage
                    self.image = Image(uiImage: scaledImage)
                }
            } else {
                print("Failed to convert Image to UIImage")
            }
        }
    }
    
    func resetImage() {
        uiImage = nil
        image = nil
    }
}

extension UIImage {
    func scaleToWidth(_ width: CGFloat) -> UIImage {
        let scaleFactor = width / size.width
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: width, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func scaleToHeight(_ height: CGFloat) -> UIImage {
        let scaleFactor = height / size.height
        let newWidth = size.width * scaleFactor
        let newSize = CGSize(width: newWidth, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
