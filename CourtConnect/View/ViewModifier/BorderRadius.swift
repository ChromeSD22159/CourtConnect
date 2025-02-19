//
//  BorderRadius.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import SwiftUI

extension View {
    func borderRadius(_ radius: CGFloat) -> some View {
        modifier(BorderRadius(radius: radius))
    }
}
struct BorderRadius: ViewModifier {
    let radius: CGFloat
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
