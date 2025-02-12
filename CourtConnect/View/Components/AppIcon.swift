//
//  AppIcon.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.02.25.
//
import SwiftUI

struct AppIcon: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Material.ultraThinMaterial)
                .frame(width: 200, height: 200)
                .shadow(radius: colorScheme == .light ? 0 : 15, y: colorScheme == .light ? 0 : 15 )
            
            Image(.authLogo)
                .resizable()
                .frame(width: 320, height: 320)
                .offset(y: -50)
                .shadow(color: colorScheme == .light ? .black.opacity(0.5) : .black ,radius: 10, y: 10)
        }
        .compositingGroup()
        .shadow(radius: 15, y: 15)
    }
}

#Preview {
    @Previewable @State var scrollPosition = ScrollPosition()
    AppBackground {
        AppIcon()
    }
}
