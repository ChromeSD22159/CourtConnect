//
//  DashboarAccountSwitch.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct DashboarAccountSwitch: View {
    let accounts: [UserAccount]
    @State private var useraccounts: [UserAccount] = []
 
    let onComplete: (UserAccount) -> Void
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    var body: some View {
        VStack(alignment: .center) { 
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(useraccounts.chunked(into: 2), id: \.self) { row in
                    ForEach(row, id: \.self) { item in
                        VStack {
                            if !item.displayName.isEmpty {
                                let width: CGFloat = (screenWidth / 2) - (16 * 1.5)
                                Text(item.displayName)
                                    .frame(width: width, height: width)
                                    .background(Material.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                        .onTapGesture {
                            onComplete(item)
                        }
                    }
                }
            }
            Spacer()
        }
        .ignoresSafeArea()
        .onTapGesture {
            animate()
        }
        .onAppear {
            animate()
        }
    }
    
    func animate() {
        Task {
            useraccounts = []
            
            for account in accounts {
                try await Task.sleep(for: .seconds(0.2))
                withAnimation {
                    useraccounts.insert(account, at: useraccounts.count)
                }
            }
        }
    }
}

struct FrameView<Content: View>: View {
    let geometry: GeometryProxy
    let content: (CGFloat) -> Content

    init(geometry: GeometryProxy, @ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.geometry = geometry
        self.content = content
    }

    var body: some View {
        let size = geometry.size.width / 2 - 25

        content(size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview { 
    DashboarAccountSwitch(accounts: MockUser.userAccountList) { _ in}
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
