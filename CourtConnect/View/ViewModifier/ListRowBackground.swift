//
//  ListRowBackground.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.02.25.
//
import SwiftUI

extension View {
    func blurrylistRowBackground() -> some View {
        modifier(BlurrylistRowBackground())
    }
    
    func blurryBackground(opacity: CGFloat = 0.5, blur: CGFloat = 100) -> some View {
        modifier(BlurryBackground(opacity: opacity, blur: blur))
    }
}

struct BlurrylistRowBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accentColor(Theme.headlineReversed)
            .listRowBackground(Color.gray.opacity(0.5).blur(radius: 100, opaque: false))
    }
}

struct BlurryBackground: ViewModifier {
    let opacity: CGFloat
    let blur: CGFloat
    func body(content: Content) -> some View {
        content
            .accentColor(Theme.headlineReversed)
            .background(Color.gray.opacity(opacity).blur(radius: blur, opaque: false))
    }
}
