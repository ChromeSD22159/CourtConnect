//
//  UserToolBar.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import SwiftUI

struct UserToolBar: ViewModifier {
    @ObservedObject var userViewModel: SharedUserViewModel
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "person.fill")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                        
                        MenuButton(icon: "figure") {
                            Button("Player") {}
                            Button("Trainer") {}
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
    }
}

extension View {
    /// REQUIRE
    func userToolBar(userViewModel: SharedUserViewModel) -> some View {
        modifier(UserToolBar(userViewModel: userViewModel))
    }
}
