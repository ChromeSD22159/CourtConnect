//
//  DocumentOverlayView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI

struct DocumentOverlayView: View {
    @Binding var document: Document?
    let viewPort = UIScreen.main.bounds.size
    @State private var shareableImage: Image?
    @State var imageSize: CGSize = .zero
    var body: some View {
        if let document = document {
            VStack(spacing: 20) {
                
                AsyncCachedImage(url: URL(string: document.url)!) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: viewPort.width * 0.6, height: viewPort.width * 0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .onAppear {
                            shareableImage = image
                        }
                        .saveSize(in: $imageSize)
                } placeholder: {
                    ZStack {
                        Image(systemName: "doc")
                            .font(.largeTitle)
                            .padding(20)
                    }
                }
                
                HStack {
                    Text(document.name)
                    
                    Spacer()
                    
                    if let shareableImage = shareableImage {
                        ShareLink(item: shareableImage, preview: SharePreview(document.name, image: shareableImage)) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .padding(32)
            .blurryBackground(opacity: 0.8)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(radius: 10)
            .transition(
                AnyTransition.move(edge: .bottom)
                    .combined(with: .scale(scale: 0.6, anchor: .top))
            )
            .overlay(alignment: .topTrailing, content: {
                ZStack {
                    Circle()
                        .fill(Material.ultraThinMaterial)
                        .frame(width: 30)
                        .shadow(radius: 2, x: -5, y: 5)
                        
                    Image(systemName: "xmark")
                }
                .offset(x: 10, y: -10)
                .onTapGesture {
                    self.document = nil
                }
            })
            .frame(width: imageSize.width + 64)
        }
    }
} 
