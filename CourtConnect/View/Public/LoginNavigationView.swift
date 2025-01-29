//
//  LoginNavigation.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI 

struct LoginNavigation: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    
    @State var userAccountViewModel: UserAccountViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
        self.userAccountViewModel = UserAccountViewModel(repository: userViewModel.repository, userId: userViewModel.user?.id)
    }
    
    var body: some View {
        ZStack {
            if userViewModel.user != nil {
                MainNavigationView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
            } else {
                LoginEntryView(userViewModel: userViewModel)
            }
        } 
        .task {
            userViewModel.isAuthendicated()
        }
    }
}

#Preview {
    LoginNavigation(userViewModel: SharedUserViewModel(repository: RepositoryPreview.shared))
        .previewEnvirments()
}
