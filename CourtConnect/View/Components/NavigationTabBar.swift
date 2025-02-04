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
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            content()
        }
        .overlay(alignment: .bottom, content: {
            HStack(spacing: 15) {
                ForEach(NavigationTab.allCases) { item in
                    tabItem(item: item)
                }
            }
            .padding(5)
            .frame(maxWidth: .infinity)
            .background(Material.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
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
        .background(Theme.background)
    }
    .preferredColorScheme(.light)
}
