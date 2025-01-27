//
//  CelebratingAnimation.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 26.01.25.
//

import Lottie
import SwiftUI
 
struct CelebratingAnimation: View {
    @State private var playbackMode: LottiePlaybackMode = LottiePlaybackMode.paused
    @State var isVisible: Bool = true
    var duration: Double
    var body: some View {
        if isVisible {
            LottieView(animation: .named("celebrating"))
                .playbackMode(playbackMode)
                .frame(width: .infinity, height: .infinity)
                .onAppear {
                    playbackMode = .playing(.fromFrame(1, toFrame: 60, loopMode: .loop))
                    
                    Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                        withAnimation {
                            playbackMode = .paused
                            isVisible.toggle()
                        }
                    }
                }
        }
    }
}

#Preview {
    CelebratingAnimation(duration: 2.0)
}
