//
//  LoginNavigation.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI 

struct LoginNavigation: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
    }
    
    var body: some View {
        ZStack {
            if userViewModel.user != nil {
                MainNavigationView(userViewModel: userViewModel)
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
