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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(useraccounts.chunked(into: 2), id: \.self) { row in
                        ForEach(row, id: \.self) { item in
                            FrameView(geometry: geometry) { size in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Material.ultraThinMaterial)
                                        .frame(width: size, height: size)
                                        .scaleEffect(1)
                                    
                                    Text(item.role)
                                }
                                .onTapGesture {
                                    onComplete(item)
                                }
                            }
                        }
                    }
                }
                .padding()
                
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
    }
    
    func animate() {
        Task {
            useraccounts = []
            
            for index in 0...3 {
                try await Task.sleep(for: .seconds(0.2))
                withAnimation {
                    let userAccount: UserAccount

                    if index < accounts.count {
                        userAccount = accounts[index]
                    } else {
                        print("asdasdasd")
                        userAccount = UserAccount(id: UUID(), userId: UUID(), position: "asd", role: "asd", displayName: "asdasd", createdAt: Date(), updatedAt: Date())
                    }

                    useraccounts.append(userAccount)
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
