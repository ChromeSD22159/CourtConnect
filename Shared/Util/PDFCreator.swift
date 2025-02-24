//
//  PDFCreator.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
// 
import Foundation
import SwiftUI
import PDFKit
 
class PDFCreator {
    let size: PDFDinFormat
    let page: PDFInfo
    
    private let metaData = [ 
        kCGPDFContextAuthor: "CourtConnect",
        kCGPDFContextSubject: "Hourly report PDF from CourtConnect App"
    ]
    
    private var rect: CGRect {
        return CGRect(x: 0, y: 0, width: size.pageWidth * PDFDinFormat.dotsPerInch, height: size.pageHeight * PDFDinFormat.dotsPerInch)
    }
    
    init(page: PDFInfo, size: PDFDinFormat) {
        self.page = page
        self.size = size
    }
    
    @MainActor
    func createPDFData(displayScale: CGFloat) -> URL? {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = metaData as [String : Any]
        let renderer = UIGraphicsPDFRenderer(bounds: rect, format: format)
        
        let tempFolder = FileManager.default.temporaryDirectory
        guard let title = page.title.stringValue() else { return nil }
        
        let fileName = "\(title)_\(UUID().uuidString).pdf"
        let tempURL = tempFolder.appendingPathComponent(fileName)
        
        try? renderer.writePDF(to: tempURL) { context in
            context.beginPage()
            let imageRenderer = ImageRenderer(content: SaleryPDF(info: page, size: size))
            imageRenderer.scale = displayScale
            imageRenderer.uiImage?.draw(at: CGPoint.zero)
        }

        return tempURL
    }
    
    func createPDFImage(data: URL) -> UIImage? {
        if let pdfDocument = PDFDocument(url: data),
           let pdfPage = pdfDocument.page(at: 0) {
            let pageSize = pdfPage.bounds(for: .cropBox)
            let image = pdfPage.thumbnail(of: pageSize.size, for: .cropBox)
            
            return image
        } else {
            return nil
        }
    }
    
    enum PDFDinFormat {
        case dinA4
        
        static let dotsPerInch: CGFloat = 72.0
        static let inch: CGFloat = 25.4
        
        var pageWidth: CGFloat {
            switch self {
            case .dinA4: return 210.0 / PDFDinFormat.inch
            }
        }
        
        var pageHeight: CGFloat {
            switch self {
            case .dinA4: return 297.0 / PDFDinFormat.inch
            }
        }
    }
}
