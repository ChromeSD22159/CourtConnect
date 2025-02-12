//
//  AppBackground.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftUI

struct AppBackground<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder var content: () -> Content
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Theme.backgroundGradient.opacity(0.5)
            } else {
                Theme.backgroundGradient.opacity(0.5)
            }
            
            Image(.basketballSketch)
                .resizable()
                .frame(width: 500, height: 500)
                .blendMode(colorScheme == .light ? .multiply : .hardLight)
                .opacity(0.3)
                .position(
                    x: UIScreen.main.bounds.width - 100,
                    y: UIScreen.main.bounds.height - 100
                )
                .clipped()
            
            content()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground {
        
    }    
}
