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
     
    init(repository: Repository) {
        self.navigationView = .login
        self.userViewModel = SharedUserViewModel(repository: repository)
    }
    
    var body: some View {
        ZStack {
            if userViewModel.user != nil {
                MainNavigationView(userViewModel: userViewModel)
            } else {
                switch navigationView {
                case .login: LoginView(userViewModel: userViewModel, navigate: handleNavigate)
                case .register: RegisterView(userViewModel: userViewModel, navigate: handleNavigate)
                case .forget: EmptyView()
                }
            }
        }
        .task {
            userViewModel.isAuthendicated()
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
