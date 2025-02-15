//
//  DocumentScrollView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI

struct DocumentScrollView: View {
    var documents: [Document]
    let onClick: (Document) -> Void
    var body: some View {
        Row(title: "Documents") {
            if !documents.isEmpty {
                SnapScrollView {
                    LazyHStack {
                        ForEach(documents) { document in
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Material.ultraThinMaterial)
                                
                                VStack {
                                    
                                    AsyncCachedImage(url: URL(string: document.url)!) { image in
                                        ClippedImage(image, width: 100, height: 100)
                                          .clipShape(RoundedRectangle(cornerRadius: 15))
                                    } placeholder: {
                                        DocSystemIcon()
                                    }
                                    
                                    Text(document.name)
                                }
                                .onTapGesture {
                                    onClick(document)
                                }
                            }
                            .frame(width: 150, height: 150)
                        }
                    }
                }
                .frame(height: 180)
            } else {
                ZStack {
                    SnapScrollView {
                        LazyHStack {
                            ForEach((1...3), id: \.self) { document in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Material.ultraThinMaterial)
                                    
                                    VStack {
                                        DocSystemIcon()
                                       
                                        Text("File \(document)")
                                    }
                                }
                                .frame(width: 150, height: 150)
                            }
                        }
                    }
                    .blur(radius: 3)
                    .opacity(0.5)
                    
                    Text("No Documents Available")
                }
                .frame(height: 180)
            }
        }
    }
}  
