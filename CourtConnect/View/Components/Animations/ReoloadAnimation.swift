//
//  ReoloadAnimation.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import SwiftUI
import Lottie

struct ReoloadAnimation: View {
    @State private var isLoading: Bool = false
    @ObservedObject private var syncViewModel = SyncViewModel.shared
    let withBackground: Bool
    var body: some View {
        ZStack {
            if isLoading {
                HStack {
                    Spacer()
                    LottieView(animation: .named("basketballLoading"))
                        .playbackMode(.playing(.fromFrame(1, toFrame: 48, loopMode: .loop)))
                        .frame(width: 150)
                        .frame(height: 75)
                        .padding(.horizontal)
                    Spacer()
                }
                .background(withBackground ? Material.ultraThinMaterial.opacity(0.9) as! Color : Color.clear)
                .borderRadius(25)
                .opacity(isLoading ? 1 : 0)
                .animation(.easeInOut.delay(0.5), value: isLoading)
                .transition(.move(edge: .top))
            }
        }
        .onAppear {
            isLoading.toggle()
            syncViewModel.fetchDataFromRemote()
        }
        .onDisappear {
            isLoading.toggle()
        }
    }
}

#Preview {
    ReoloadAnimation(withBackground: true)
}
