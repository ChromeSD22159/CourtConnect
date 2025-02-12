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
            
            Image(.courtBG)
                .resizable()
                .scaledToFill()
                .opacity(0.25) 
            
            content()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground {
        
    }    
}
