//
//  ConfettiOverlay.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI
import Lottie

struct ConfettiOverlay<Content: View>: View {
    @State var confetti = ConfettiViewModel.shared
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            
            if confetti.isAnimating {
                LottieView(animation: .named("celebrating"))
                    .playbackMode(.playing(.fromFrame(1, toFrame: 48, loopMode: .loop)))
            }
        }
    }
}

#Preview {
    @Previewable @State var confetti = ConfettiViewModel.shared
    ConfettiOverlay {
        Text("asdasdsd")
            .onTapGesture {
                confetti.trigger()
            }
    }
}
