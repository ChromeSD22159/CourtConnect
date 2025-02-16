//
//  NavigationTabBar.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI

struct NavigationTabBar<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var navViewModel: NavigationViewModel
    @Namespace private var animation
    
    @State var isScrolling = false
    @State var reload = false
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            if colorScheme == .light {
                Theme.backgroundGradient.opacity(0.8)
            } else {
                Theme.backgroundGradient
            }
            
            Image(.courtBG)
                .resizable()
                .scaledToFit()
                .opacity(0.25)
            
            ScrollRefreshable(
                options: ScrollOptions(
                    contentMarginsLength: 95,
                    contentMarginsEdges: .top,
                    verticalSpacing: 20
                ),
                refresh: {
                    ReoloadAnimation(withBackground: false)
                },
                content: content
            )
            .onScrollPhaseChange({ _, newPhase in
                withAnimation(.spring) {
                    isScrolling = newPhase.isScrolling
                }
            })
        }
        .onAppear {
            navViewModel.inizializeAuth()
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom, content: {
            ZStack {
                if !isScrolling {
                    ZStack {
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
                        .padding(.vertical, 10)
                        .padding(.horizontal, 40)
                        .background {
                            Capsule()
                                .fill(Material.ultraThinMaterial.opacity(0.97))
                                .blur(radius: 2)
                                .padding(5)
                                .frame(maxHeight: 75)
                                .clipShape(Capsule())
                                .padding(.horizontal, 20)
                                .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
                        }
                    }
                    .transition(.move(edge: .bottom))
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
        .frame(width: 75, height: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            navViewModel.navigateTo(item)
        }
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme
    ZStack {
        if colorScheme == .light {
            Theme.backgroundGradient.opacity(0.8)
        } else {
            Theme.backgroundGradient
        }
        Image(.courtBG)
            .resizable()
            .scaledToFit()
            .opacity(0.25)
            .clipped()

        ScrollView {
            RoundedRectangle(cornerRadius: 25)
                .fill(Material.ultraThinMaterial.opacity(0.5))
                .frame(width: .infinity, height: 400)
            
            RoundedRectangle(cornerRadius: 25)
                .fill(Material.ultraThinMaterial.opacity(0.5))
                .frame(width: .infinity, height: 400)
            
            RoundedRectangle(cornerRadius: 25)
                .fill(Material.ultraThinMaterial.opacity(0.5))
                .frame(width: .infinity, height: 400)
        }
        .contentMargins(20)
    }
    .ignoresSafeArea()
    .overlay(alignment: .bottom, content: {
        ZStack {
            Capsule()
                .fill(Material.ultraThinMaterial)
                .blur(radius: 2)
                .padding(5)
                .frame(maxWidth: .infinity, maxHeight: 75)
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(1.0), radius: 20, y: 10)
               
            HStack {
                Text("Hallo")
                
                Text("Hallo")
                
                Text("Hallo")
            }
        }
        .transition(.move(edge: .bottom))
    })
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
    }
    .preferredColorScheme(.light)
}
