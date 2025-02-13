//
//  ListBackground.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI

extension View {
    func listBackground() -> some View {
        modifier(ListBackground())
    }
    
    func listBackgroundAnimated() -> some View {
        modifier(ListBackgroundAnimated())
    }
}

struct ListBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .contentMargins(.horizontal, 20)
            .background(Theme.backgroundGradient)
    }
}

struct ListBackgroundAnimated: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .contentMargins(.horizontal, 20) 
    }
}
