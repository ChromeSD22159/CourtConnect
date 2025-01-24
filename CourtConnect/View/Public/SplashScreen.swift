//
//  SplashScreen.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftUI
import Lottie

struct SplashScreen: View {
    @State private var playbackMode: LottiePlaybackMode = LottiePlaybackMode.paused
    var duration: Double // 2
    @Binding var isVisible: Bool
    @State var logoVisibility = true
    @State var animationVisibility = true
    
    let onComplete: () -> Void
    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
                Image(.logo)
                    .resizable()
                    .frame(width: 200  ,height: 200)
                    .offset(y: 100)
                    .opacity(logoVisibility ? 1 : 0)
                
                LottieView(animation: .named("basketballLoading"))
                    .playbackMode(playbackMode)
                    .frame(width: 400, height: 400)
            }
            .onAppear {
                playbackMode = .playing(.fromFrame(1, toFrame: 48, loopMode: .loop))
                
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    withAnimation {
                        logoVisibility.toggle()
                    }
                }
                
                Timer.scheduledTimer(withTimeInterval: duration * 2, repeats: false, block: { _ in
                    withAnimation {
                        onComplete()
                    }
                })
            }
        }
    }
}

#Preview {
    @Previewable @State var isSlashScreen = true
    SplashScreen(duration: 3.0, isVisible: $isSlashScreen) {
        isSlashScreen.toggle()
    }
}
