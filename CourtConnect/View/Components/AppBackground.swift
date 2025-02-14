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
                    .ignoresSafeArea()
            } else {
                Theme.backgroundGradient.opacity(0.5)
                    .ignoresSafeArea()
            }
            
            if let image: ImageResource = .courtBG {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.25)
                    .ignoresSafeArea()
            }
            
            content()
        }
        .errorPopover()
    }
}

#Preview {
    AppBackground {
        
    }    
}
