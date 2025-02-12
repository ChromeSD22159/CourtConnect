//
//  AnimationBackgroundChange.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.02.25.
//
import SwiftUI

struct AnimationBackgroundChange<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Namespace var namespace
    @State var show = false
    @ViewBuilder var content: () -> Content
    var body: some View {
        ZStack {
            if colorScheme == .light {
                if !show {
                    Theme.backgroundGradient.opacity(0.8).ignoresSafeArea()
                } else {
                    Theme.backgroundGradientReverse.ignoresSafeArea()
                }
            } else {
                if !show {
                    Theme.backgroundGradient.ignoresSafeArea()
                } else {
                    Theme.backgroundGradientReverse.ignoresSafeArea()
                }
            }
            content()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2.0).delay(0.3)) {
                show.toggle()
            }
        }
    }
}

#Preview {
    AnimationBackgroundChange {
        
    }
}
