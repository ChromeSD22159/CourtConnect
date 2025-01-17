//
//  DashboardView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI

struct DashboardView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = userViewModel.user, let email = user.email {
                    BodyText(email)
                }
                
                VStack {
                    Text("Online User: \(userViewModel.onlineUserCount)")
                    HStack {
                        Button("Online") {
                            userViewModel.setUserOnline()
                        }
                        
                        Button("Offline") {
                            userViewModel.setUserOffline()
                        }
                    }
                    .padding(.top, 50)
                }
                
            }
            .navigationTitle("Daskboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "person.fill")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                    }
                }
            }
            .onAppear {
                userViewModel.onAppDashboardAppear()
            }
        }
    }
}

#Preview {
    DashboardView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
}
