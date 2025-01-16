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
        VStack(spacing: 20) {
            if let user = userViewModel.user, let email = user.email {
                BodyText(email)
            }
            
            Button("Logout") {
                userViewModel.signOut()
            }
        }
        .sheet(isPresented: $userViewModel.showOnBoarding, content: {
            UserProfileEditView(userViewModel: userViewModel)
        })
        .navigationTitle("Daskboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Image(systemName: "person.fill")
                        .padding(10)
                        .onTapGesture {
                            userViewModel.showOnBoarding = true
                        }
                    
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .padding(10)
                        .onTapGesture {
                            userViewModel.showOnBoarding = true
                        }
                }
            }
        }
        .onAppear {
            userViewModel.onAppDashboardAppear()
        }
    }
}

#Preview {
    DashboardView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
}
