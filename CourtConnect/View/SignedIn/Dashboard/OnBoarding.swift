//
//  OnBoarding.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI

struct OnBoardingView: View {
    @Environment(\.dismiss) var dismiss 
    @State var confetti = ConfettiViewModel.shared
    @State var showName = false
    
    let userProfile: UserProfile
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            ConfettiOverlay {
                VStack(spacing: 100) {
                    Text("**Welcome** \n\(userProfile.firstName)!")
                        .lineSpacing(20)
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .foregroundStyle(.onBackground)
                        .opacity(showName ? 1 : 0)
                        .animation(.easeInOut.delay(0.5), value: showName)
                    
                    Button("continue") {
                        Task {
                            userProfile.onBoardingAt = Date()
                            dismiss()
                        }
                    }
                    .padding()
                    .font(.body.bold())
                    .foregroundStyle(.white)
                    .background(Theme.darkOrange)
                    .borderRadius(15)
                    .opacity(showName ? 1 : 0)
                    .animation(.easeInOut.delay(1.5), value: showName)
                }
            }
        }
        .onAppear {
            Task {
                try await Task.sleep(for: .seconds(0.5))
                confetti.trigger()
                showName.toggle()
            }
        }
    }
}

#Preview {
    OnBoardingView(userProfile: MockUser.myUserProfile)
        .previewEnvirments()
}
