//
//  LoginNavigation.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI
import Supabase

struct LoginNavigation: View {
    @State var navigationView: LoginNavigationView
    @State var userViewModel: SharedUserViewModel
    
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
        self.navigationView = .login
        self.userViewModel = SharedUserViewModel(repository: repository)
    }
    
    var body: some View {
        ZStack {
            if userViewModel.user != nil {
                MainNavigationView(repository: repository, userViewModel: userViewModel)
            } else {
                switch navigationView {
                case .login: LoginView(repository: repository, userViewModel: userViewModel, navigate: handleNavigate)
                case .register: RegisterView(repository: repository, userViewModel: userViewModel, navigate: handleNavigate)
                case .forget: EmptyView()
                }
            }
        }
        .task {
            await repository.userRepository.isAuthendicated { (user: User?, userProfile: UserProfile?) in
                withAnimation {
                    userViewModel.user = user
                    userViewModel.userProfile = userProfile 
                }
            }
        }
        
    }
    
    private func handleNavigate(to: LoginNavigationView) {
        withAnimation {
            self.navigationView = to
        }
    }
}



enum LoginNavigationView {
    case login, register, forget
}

#Preview {
    LoginNavigation(repository: Repository(type: .preview))
}
