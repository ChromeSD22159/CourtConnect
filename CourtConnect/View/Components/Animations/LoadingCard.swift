//
//  LoadingCard.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import Lottie
import SwiftUI

struct LoadingCard: View {
    @Binding var isLoading: Bool
    var body: some View {
        if isLoading {
            VStack {
                LottieView(animation: .named("basketballLoading"))
                    .playbackMode(.playing(.fromFrame(1, toFrame: 48, loopMode: .loop)))
                    .frame(width: 200, height: 200)
                
                Text("Loading...")
                    .offset(y: -40)
            }
            .background(Material.ultraThinMaterial.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .opacity(isLoading ? 1 : 0)
            .animation(.easeInOut.delay(0.5), value: isLoading)
        }
    }
}
