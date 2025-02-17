//
//  AppBackground.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftUI

struct AppBackground<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder var content: () -> Content
    var body: some View {
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
                .opacity(0.25)
                .ignoresSafeArea()
                .clipped()
            
            content()
        }
        .errorPopover()
    }
}

extension View {
    func appBackgroundModifier() -> some View {
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
                        .opacity(0.25)
                        .ignoresSafeArea()
                        .clipped()
                }
            }
    }
}

#Preview {
    
    ZStack {
        NavigationStack {
            AppBackground {
                NavigationLink(destination: {
                    Text("Detail")
                        .navigationTitle("Detail")
                }, label: {
                    Text("label")
                })
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Hallo")
                    }
                }
            }
        }
    }
}
