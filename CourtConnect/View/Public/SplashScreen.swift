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
    @ObservedObject var syncServiceViewModel: SyncServiceViewModel
    
    let duration: Double // 2
    let userId: UUID?
    let onComplete: () -> Void
     
    @State var logoVisibility = true
    @State var animationVisibility = true
    @State private var playbackMode: LottiePlaybackMode = LottiePlaybackMode.paused
     
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
            .task {
                if let userId = userId {
                    do {
                        try await syncServiceViewModel.syncAllTables(userId: userId)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
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
    
    SplashScreen(isVisible: $isSlashScreen, syncServiceViewModel: SyncServiceViewModel(repository: Repository(type: .preview)), duration: 3.0, userId: nil, onComplete: {
        isSlashScreen.toggle()
    })
}
