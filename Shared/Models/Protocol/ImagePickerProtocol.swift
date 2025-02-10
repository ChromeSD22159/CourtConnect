//
//  ImagePickerProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 08.02.25.
// 
import Foundation
import SwiftUI 
import PhotosUI

protocol ImagePickerProtocol: ObservableObject {
    var item: PhotosPickerItem? { get set }
    var image: Image? { get set }
    var uiImage: UIImage? { get set }
    var fileName: String { get set }
}

extension ImagePickerProtocol {
    func setImage() {
        Task {
            if let imageData = try? await item?.loadTransferable(type: Data.self), let uiImage = UIImage(data: imageData) {
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
