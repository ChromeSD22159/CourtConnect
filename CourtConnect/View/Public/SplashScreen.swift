//
//  SplashScreen.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftUI
import Lottie

struct SplashScreen: View {
    
    @Binding var isVisible: Bool 
    
    let duration: Double
    let userId: UUID?
    let onStart: () -> Void
    let onComplete: () -> Void
     
    @State var logoVisibility = true
    @State var animationVisibility = true
    @State private var playbackMode: LottiePlaybackMode = LottiePlaybackMode.paused
     
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
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
                .offset(y: 100)
                .opacity(logoVisibility ? 1 : 0)
                     
                LottieView(animation: .named("basketballLoading"))
                    .playbackMode(playbackMode)
                    .opacity(animationVisibility ? 1 : 0)
                    .frame(width: 400, height: 400)
            }
            .appBackgroundModifier()
            .onAppear {
                playbackMode = .playing(.fromFrame(1, toFrame: 48, loopMode: .loop))
                 
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    onStart()
                    
                    withAnimation(.spring) {
                        logoVisibility.toggle()
                    }
                    
                    withAnimation(.spring.delay(0.5)) {
                        animationVisibility.toggle()
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
    AppBackground {
        SplashScreen(isVisible: $isSlashScreen, duration: 1.5, userId: nil, onStart: {
            
        } , onComplete: {
            isSlashScreen.toggle()
        })
    }
    .previewEnvirments()
}
