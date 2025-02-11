//
//  RotationAnimationModifier.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI

extension View {
    func rotationAnimation(isFetching: Binding<Bool>) -> some View {
        modifier(RotationAnimationModifier(isFetching: isFetching))
    }
}

struct RotationAnimationModifier: ViewModifier {
    @Binding var isFetching: Bool
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isFetching ? 360 : 0))
            .animation(
                isFetching ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default,
                value: isFetching
            )
    }
}

#Preview {
    @Previewable @State var isFetching = false
    Image(systemName: "arrow.triangle.2.circlepath.circle")
        .rotationAnimation(isFetching: $isFetching)
        .onTapGesture {
            isFetching.toggle()
        }
        
}
