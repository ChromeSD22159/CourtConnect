//
//  QRCodeHelper.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 03.02.25.
//
import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeHelper {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
