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
