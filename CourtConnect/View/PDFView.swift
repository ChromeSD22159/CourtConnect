//
//  PDFView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
//
import Foundation
import SwiftUI 
import PDFKit

// MARK: - Model
struct SaleryPDF: View {
    let info: PDFInfo
    let size: PDFCreator.PDFDinFormat
    
    var oneSixten: CGFloat {
        size.pageWidth * PDFCreator.PDFDinFormat.dotsPerInch / 12
    }
    
    var body: some View {
        
        VStack {
            // MARK: - HEADCONTENT
            HStack(alignment: .bottom, spacing: 50) {
                Image(.appIcon)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .frame(width: 60, height: 60)
                    .shadow(radius: 10, x: 0, y: 10)
                
                Text(info.title)
                    .font(.title3)
                
                Spacer()
                
                Text("Created on: \(info.createdAt.toDateString())")
                    .font(.caption2)
            }
              
            // MARK: - HEADCONTENT
            HStack {
                Text(info.description)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 25)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
             
            // MARK: - TrainerDataTable
            tableHeaderRow()
            VStack(spacing: 0) {
                ForEach(info.list.indices, id: \.self) { index in
                    trainerRow(index: index, item: info.list[index])
                }
            }
            
            Spacer()
            
            // MARK: - SigningFields
            HStack {
                Text("Date / location: ___________________")
                Spacer()
                Text("Signature: ___________________")
            }
            .font(.footnote)
        }
        .padding(50)
        .frame(width: size.pageWidth * PDFCreator.PDFDinFormat.dotsPerInch, height: size.pageHeight * PDFCreator.PDFDinFormat.dotsPerInch)
       
    }
    
    @ViewBuilder func tableHeaderRow() -> some View {
        HStack {
            Text("Coach")
            Spacer()
            Divider()
            Text("Hours").frame(width: oneSixten * 1.3)
            Divider()
            Text("Rate").frame(width: oneSixten * 1.3)
            Divider()
            Text("Total").frame(width: oneSixten * 1.3)
        }
        .font(.caption2)
        .padding(.horizontal, 25)
        .frame(height: 30)
        .background(.gray.opacity(0.05))
    }
    
    @ViewBuilder func trainerRow(index: Int, item: TrainerSaleryData) -> some View {
        HStack {
            Text("\(index + 1). \(item.fullName)")
            Spacer()
            Divider()
            Text("\(item.hours.formatted(.number)) h").frame(width: oneSixten * 1.3)
            Divider()
            Text(item.hourlyRate.formatted(.currency(code: "EUR"))).frame(width: oneSixten * 1.3)
            Divider()
            Text(item.totalSalery.formatted(.currency(code: "EUR"))).frame(width: oneSixten * 1.3)
        }
        .font(.caption2)
        .padding(.horizontal, 25)
        .frame(height: 30)
        .background(.gray.opacity(index % 2 == 0 ? 0.005 : 0.01))
    }
}

// MARK: - Model
struct ShareLinkPDFView: View {
    @Environment(\.displayScale) var displayScale
    let pdfCreator: PDFCreator
    
    init(page: PDFInfo) {
        self.pdfCreator = PDFCreator(
            page: page,
            size: .dinA4
        )
    }
    
    var body: some View {
        VStack {
            if let pdf = pdfCreator.createPDFData(displayScale: displayScale) {
                ShareLink(item: pdf) {
                    HStack(spacing: 25) {
                        Image(systemName: "doc.text.image")
                            .font(.title)
                        
                        Text("Hourly report")
                            .font(.title3)
                    }
                }
                .buttonStyle(DarkButtonStlye())
            }
        }
        .padding()
    }
}

struct TimeRecordingImage: View {
    @Environment(\.displayScale) var displayScale
    let pdfCreator: PDFCreator
    @State var dataUrl: URL?
    
    init(page:PDFInfo) {
        let page = page
        self.pdfCreator = PDFCreator(
            page: page,
            size: .dinA4
        )
    }
    
    var body: some View {
        ZStack {
            if let dataUrl = dataUrl, let image = pdfCreator.createPDFImage(data: dataUrl) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            dataUrl = pdfCreator.createPDFData(displayScale: displayScale)
        }
    }
}

#Preview {
    let list = [
        TrainerSaleryData(fullName: "Frederik Kohler", hours: 5, hourlyRate: 12.99),
        TrainerSaleryData(fullName: "Vorname Nachname", hours: 5, hourlyRate: 12.99)
    ]
    
    let page = PDFInfo(image: Image(.appIcon), list: list, createdAt: Date())
    
    ZStack {
        Color.gray
        
        VStack {
            TimeRecordingImage(page: page)
            ShareLinkPDFView(page: page)
        }.padding()
    }
    .ignoresSafeArea()
    
}
