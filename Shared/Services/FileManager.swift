//
//  FileManager.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import Foundation
import UIKit

struct FileService {
    let fileManager = FileManager.default
    let filesURL: URL
    
    init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filesURL = documentsURL.appendingPathComponent("Files")

        do {
            try fileManager.createDirectory(at: filesURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
    
    private func save(data: Data, filename: String) throws -> URL {
        let fileURL = filesURL.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }

    private func load(filename: String) throws -> Data {
        let fileURL = filesURL.appendingPathComponent(filename)
        return try Data(contentsOf: fileURL)
    }
 
    private func url(for filename: String) -> URL {
        return filesURL.appendingPathComponent(filename)
    }
    
    func saveImage(fileName: String, image: UIImage) throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw FileManagerError.canNotSaveImage }
        return try FileService().save(data: imageData, filename: fileName)
    }
    
    func savePDF(pdfData: Data, filename: String) throws -> URL {
        do {
            return try save(data: pdfData, filename: filename)
        } catch {
            throw FileManagerError.canNotSavePdf
        }
    }
    
    func loadImage(fileName: String) throws -> UIImage? {
        let loadedImageData = try self.load(filename: fileName)
        return UIImage(data: loadedImageData)
    }
    
    func loadPdf(fileName: String) throws -> Data {
        return try load(filename: fileName)
    }
    
    func delete(filename: String) -> Bool {
        let fileURL = filesURL.appendingPathComponent(filename)
        do {
            try fileManager.removeItem(at: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    static func printDocumentDirectory() {
        if let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Document Directory: \(documentDirectoryURL.path)")
        }
    }
    
    enum FileKind {
        case image, pdf
    }

    enum FileManagerError: Error, LocalizedError {
        case canNotReadImage, canNotReadPdf
        case canNotSaveImage, canNotSavePdf
    }
}
