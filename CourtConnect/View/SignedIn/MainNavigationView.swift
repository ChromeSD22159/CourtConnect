//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    let repository: Repository
    
    @ObservedObject var userViewModel: SharedUserViewModel
    
    init(
        repository: Repository,
        @ObservedObject userViewModel: SharedUserViewModel
    ) {
        self.repository = repository
        self.userViewModel = userViewModel
    }
    
    @State var showOnBoarding = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = userViewModel.user, let email = user.email {
                    BodyText(email)
                }
                
                Button("Logout") {
                    userViewModel.signOut()
                }
            }
            .sheet(isPresented: $showOnBoarding, content: {
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
                                showOnBoarding = true
                            }
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .padding(10)
                            .onTapGesture {
                                showOnBoarding = true
                            }
                    }
                }
            }
            .onAppear {
                if userViewModel.userProfile == nil {
                    showOnBoarding.toggle()
                }
            }
        }
    }
}
 
#Preview {
    let repo = Repository(type: .preview)
    MainNavigationView(repository: repo, userViewModel: SharedUserViewModel(repository: repo))
}
