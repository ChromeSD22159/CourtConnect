//
//  CacheConfig.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.02.25.
//
import Foundation
 
struct CacheConfig {
    static let shared = CacheConfig()  

    init() {
        let memoryCapacity = 500 * 1024 * 1024 // 500 MB
        let diskCapacity = 500 * 1024 * 1024 // 500 MB
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, directory: nil)
        URLCache.shared = urlCache

        print("URLCache konfiguriert (memoryCapacity: \(memoryCapacity.formatted(.byteCount(style: .file))), diskCapacity: \(diskCapacity.formatted(.byteCount(style: .file))))")
    }
}
