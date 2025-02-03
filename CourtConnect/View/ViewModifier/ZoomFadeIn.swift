//
//  ZoomFadeIn.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI

extension View {
    func zoomFadeIn(delay: Double, trigger: Binding<Bool>) -> some View {
        modifier(ZoomFadeIn(delay: delay, trigger: trigger))
    }
} 

struct ZoomFadeIn: ViewModifier {
    let delay: Double
    @Binding var trigger: Bool
    private let scaleEffect: (start: Double, end: Double) = (0.5, 1.0)
    private let opacityEffect: (start: Double, end: Double) = (0.0, 1.0)
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(trigger ? scaleEffect.end : scaleEffect.start)
            .opacity(trigger ? opacityEffect.end : opacityEffect.start)
            .animation(.easeIn.delay(delay), value: trigger)
    }
}
