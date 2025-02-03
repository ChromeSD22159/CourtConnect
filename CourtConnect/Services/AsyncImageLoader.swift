//
//  AsyncImageLoader.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import Foundation
import UIKit
import Combine

class AsyncImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var cancellable: AnyCancellable?
    private static let cache = ImageCache.shared

    init(url: URL?) {
        loadImage(from: url)
    }

    private func loadImage(from url: URL?) {
        guard let url = url else {
            return
        }

        /// Überprüfen, ob das Bild bereits im Cache ist
        if let cachedImage = AsyncImageLoader.cache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }

        /// Bild herunterladen und cachen
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self, let image = image else { return }
                AsyncImageLoader.cache.setObject(image, forKey: url.absoluteString as NSString)
                self.image = image
            }
    }

    deinit {
        cancellable?.cancel()
    }
}

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}

class ImageCacheHelper {
    static let shared = ImageCacheHelper()
    
    private let urlSession = URLSession.shared
    private var cancellables: AnyCancellable?
    
    func cacheImage(url: URL) {
        cancellables = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { image in
                guard let image = image else { return }
                ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
            }
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
