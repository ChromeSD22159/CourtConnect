//
//  ClippedImage.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 15.02.25.
//
import SwiftUI

struct ClippedImage: View {
    let imageName: Image
    let width: CGFloat
    let height: CGFloat

    init(_ imageName: Image, width: CGFloat, height: CGFloat) {
        self.imageName = imageName
        self.width = width
        self.height = height
    }
    var body: some View {
        ZStack {
            imageName
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
        }
        .cornerRadius(0) // Necessary for working
        .frame(width: width, height: height)
    }
} 
