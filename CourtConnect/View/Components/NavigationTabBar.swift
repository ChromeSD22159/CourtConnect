//
//  NavigationTabBar.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI

struct NavigationTabBar<Content: View>: View {
    @ObservedObject var navViewModel: NavigationViewModel
    @Namespace private var animation
    @State var isScrolling = false
    @State var reload = false
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            Theme.background
            
            ScrollView(.vertical) {
                content()
            }
            .scrollIndicators(.hidden)
            .contentMargins(.top, 95)
            .onScrollPhaseChange({ _, newPhase in
                withAnimation(.easeInOut) {
                    isScrolling = newPhase.isScrolling
                }
            })
        }
        .onAppear {
            navViewModel.inizializeAuth()
        }
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            ReoloadAnimation(isLoading: $reload)
        }
        .overlay(alignment: .bottom, content: {
            ZStack {
                if !isScrolling {
                    ZStack {
                        Capsule()
                            .fill(Material.ultraThinMaterial)
                            .blur(radius: 2)
                            .padding(5)
                            .frame(maxWidth: .infinity, maxHeight: 75)
                            .clipShape(Capsule())
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
                           
                        HStack {
                            ForEach(NavigationTab.allCases) { item in
                                if navViewModel.userAccount?.roleEnum == .player {
                                    if item == .player {
                                        tabItem(item: item)
                                    } else {
                                        tabItem(item: item)
                                    }
                                } else { 
                                    if item != .player {
                                        tabItem(item: item)
                                    }
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .background {
                        LinearGradient(
                            colors: [
                                Theme.background.opacity(1.0),
                                Theme.background.opacity(0.0)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .ignoresSafeArea()
                    }
                }
            }
        })
    }
    
    @ViewBuilder func tabItem(item: NavigationTab) -> some View {
        let isActive = navViewModel.current == item
        
        VStack(spacing: 4) {
            Image(systemName: item.images)
            
            Text(item.name)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
            
            if isActive {
                Rectangle()
                    .fill(Theme.darkOrange)
                    .matchedGeometryEffect(id: "state", in: animation)
                    .frame(height: 5)
            } else {
                Color.clear.frame(height: 5)
            }
        }
        .frame(width: 60, height: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                navViewModel.navigateTo(item)
            }
        }
    }
}

#Preview {
    @Previewable @State var navViewModel = NavigationViewModel()
    NavigationTabBar(navViewModel: navViewModel) {
        VStack {
            let colors = [Color.red, Color.black, Color.indigo, Color.orange, Color.red, Color.black, Color.indigo, Color.orange]
            ForEach(colors, id: \.self) { color in
                HStack {
                    Text("\(color)")
                    
                    Spacer()
                }
                .padding()
                .padding()
                .padding(.top, 50)
                .background(color)
                .padding(.horizontal)
            }
        }
    }
   .preferredColorScheme(.dark)
}

#Preview {
    @Previewable @State var navViewModel = NavigationViewModel()
    NavigationTabBar(navViewModel: navViewModel) {
        ScrollView {
            let colors = [Color.red, Color.black, Color.indigo, Color.orange, Color.red, Color.black, Color.indigo, Color.orange]
            ForEach(colors, id: \.self) { color in
                HStack {
                    Text("\(color)")
                    
                    Spacer()
                }
                .padding()
                .padding(.top, 50)
                .background(color)
                .padding(.horizontal)
            }
        }
        .scrollIndicators(.hidden)
        .background(Theme.background)
    }
    .preferredColorScheme(.light)
}
