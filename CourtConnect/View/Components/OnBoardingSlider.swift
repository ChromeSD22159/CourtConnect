//
//  OnBoardingSlider.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 13.02.25.
//
import SwiftUI
 
// TODO: 
extension OnBoardingSlider {
    struct Localizations {
        static let title1: LocalizedStringKey = "Lets get started"
        static let title2: LocalizedStringKey = "onboarding_title_2"
        static let title3: LocalizedStringKey = "Lets get started"
        static let description1: LocalizedStringKey = "onboarding_description_1"
        static let description2: LocalizedStringKey = "onboarding_description_2"
        static let description3: LocalizedStringKey = "onboarding_description_2"
    }
}

struct OnBoardingSlider: View {
    @State var selection = 0
    @State var bgImage: ImageResource = .bgDark
    var list = [
        TabViewItemValue(title: Localizations.title1, description: Localizations.description1, image: .bgDark),
        TabViewItemValue(title: Localizations.title2, description: Localizations.description2, image: .courtBG),
        TabViewItemValue(title: Localizations.title3, description: Localizations.description3, image: .bgDark)
    ]
    
    @Namespace var backgroundTransition
    var body: some View {
        ZStack {
           
            Group {
                if selection == 0 {
                    ZStack {
                        Image(bgImage)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                        Theme.backgroundGradient
                    }
                } else if selection == 1 {
                    Theme.backgroundGradientReverse
                } else {
                    ZStack {
                        Image(bgImage)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                        Theme.backgroundGradient
                    }
                }
            }
            .ignoresSafeArea()
            .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 1.0)), removal: .opacity.animation(.easeInOut(duration: 1.0))))
            .matchedGeometryEffect(id: "background", in: backgroundTransition)
            
            TabView(selection: $selection) {
                ForEach(list.indices, id: \.self) { index in
                    TabViewItem(content: list[index]).tag(index)
                        .onAppear {
                            if let image = list[index].image {
                                self.bgImage = image
                            }
                        }
                }
            }
            .frame(width: .infinity, height: .infinity)
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct TabViewItemValue: Identifiable {
    var id: UUID = UUID()
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let image: ImageResource?
}

struct TabViewItem: View {
    let content: TabViewItemValue
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(content.title).multilineTextAlignment(.leading)
                .font(.largeTitle)
            
            HStack {
                Text(content.description)
                Spacer()
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background {
            RoundedRectangle(cornerRadius: 40)
                .fill(.white)
               .opacity(0.75)
               .shadow(radius: 10.0)
        }
        .padding(25)
    }
}

#Preview {
    OnBoardingSlider()
}
