//
//  AppBackground.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftUI

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}

struct AppBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    if colorScheme == .light {
                        Theme.backgroundGradient.opacity(0.5)
                            .ignoresSafeArea()
                    } else {
                        Theme.backgroundGradient.opacity(0.5)
                            .ignoresSafeArea()
                    }
                    
                    Image(.courtBG)
                        .resizable()
                        .scaledToFill()
                        .offset(y: -50)
                        .opacity(0.25)
                }
            }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            VStack {
                Spacer()
                NavigationLink(destination: {
                    Text("Detail")
                        .navigationTitle("Detail")
                }, label: {
                    HStack {
                        Spacer()
                        Text("label")
                        Spacer()
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Hallo")
                    }
                }
                
                Spacer()
            }
        }
        .appBackground()
    }
}
