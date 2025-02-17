//
//  OnBoardingSlider.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI
 
@Observable class OnboardingViewModel {
    var confetti = ConfettiViewModel.shared
    var selection = 0
    var bgImage: ImageResource = .bgDark
   
    var list: [TabViewItemValue]
    
    init(userProfile: UserProfile) {
        self.list = [
            TabViewItemValue(icon: "hand.raised.fill", title: "Hey, \(userProfile.firstName)", description: "Start exploring our app", image: .courtBG),
            TabViewItemValue(icon: "basketball.fill", title: "Welcome", description: "Start exploring our app", image: .courtBG),
            TabViewItemValue(icon: "bolt.fill", title: "Fast & Easy", description: "Quickly access what you need.", image: .courtBG),
            TabViewItemValue(icon: "sparkles", title: "Let`s Get Started!", description: "Continue to explore our app.", image: .courtBG)
        ]
    }
    
    func nextSlide() {
        if selection != (list.count - 1) {
            withAnimation(.easeInOut(duration: 1)) {
                selection += 1
            }
        }
    }
}

struct OnBoardingSlider: View {
    @State var viewModel: OnboardingViewModel
    @State var confetti = ConfettiViewModel.shared
    @Namespace var backgroundTransition
    
    init(userProfile: UserProfile) {
        viewModel = OnboardingViewModel(userProfile: userProfile)
    }

    var body: some View {
        ZStack {
            Group {
                if (viewModel.selection % 2) == 0 {
                    ZStack {
                        Image(viewModel.bgImage)
                            .resizable()
                            .scaledToFill()
                            .opacity(0.3)
                            .clipped()
                        
                        Theme.backgroundGradient
                    }
                } else {
                    ZStack {
                        Image(viewModel.bgImage)
                            .resizable()
                            .scaledToFill()
                            .opacity(0.3)
                            .clipped()
                        Theme.backgroundGradientReverse
                    }
                }
            }
            .ignoresSafeArea()
            .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 1.5)), removal: .opacity.animation(.easeInOut(duration: 1.5))))
            .matchedGeometryEffect(id: "background", in: backgroundTransition)
            
            ConfettiOverlay {
                TabView(selection: $viewModel.selection) {
                    ForEach(viewModel.list.indices, id: \.self) { index in
                        TabViewItem(content: viewModel.list[index], isLast: index == (viewModel.list.count - 1)) {
                            viewModel.nextSlide()
                        }
                        .tag(index)
                        .onAppear {
                            if let image = viewModel.list[index].image {
                                viewModel.bgImage = image
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
            .onAppear {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    confetti.trigger()
                }
            }
        }
    }
}

struct TabViewItem: View {
    @Environment(\.dismiss) var dismiss
    @State var isLastAnimataion = false
    
    let content: TabViewItemValue
    let isLast: Bool
    let next: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Image(systemName: content.icon)
                .font(.system(size: 75))
            
            Text(content.title).multilineTextAlignment(.leading)
                .font(.largeTitle)
            
            Text(content.description)
             
            Button(isLastAnimataion ? "Close" : "Next") {
                if isLastAnimataion {
                    dismiss()
                } else {
                    next()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.backgroundGradientReverse)
        }
        .task {
            if isLast {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    withAnimation(.easeIn) {
                        isLastAnimataion = true
                    }
                }
            }
        }
        .onDisappear {
            isLastAnimataion = false
        }
        .padding(25)
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding(25)
    }
}

struct TabViewItemValue: Identifiable {
    var id: UUID = UUID()
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let image: ImageResource?
}

#Preview {
    OnBoardingSlider(userProfile: MockUser.myUserProfile)
        .previewEnvirments()
}
