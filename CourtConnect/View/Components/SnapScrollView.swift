//
//  SnapScrollView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 31.01.25.
//
import SwiftUI

struct SnapScrollView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    let horizontalSpacing: CGFloat
    
    init(horizontalSpacing: CGFloat = 16, content: @escaping () -> Content) {
        self.content = content
        self.horizontalSpacing = horizontalSpacing
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                content()
                    .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, horizontalSpacing)
            .scrollIndicators(.hidden)
        }
    }
    
    func calculateCurrentIndex(from xValue: CGFloat, contentWidth: CGFloat) -> Int {
        let pageWidth = contentWidth // Width of each page/item, including spacing
        let currentPage = Int(round(-xValue / pageWidth))
        return currentPage
    }
}
