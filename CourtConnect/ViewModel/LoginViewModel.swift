//
//  LoginViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import Supabase

@Observable class LoginViewModel: ObservableObject {
    var repository: Repository
    
    var email: String = ""
    var password: String = ""
    var showPassword = false
    var keepSignededIn = true
    var focus: Field? = nil
    
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func changeFocus() {
        guard let currentFocus = focus else { return }
        switch currentFocus {
            case .email: focus = .password
            case .password: focus = nil
        }
    }
    
    func signIn(complete: @escaping (User?, UserProfile?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        Task {
            do {
                let user = try await repository.userRepository.signIn(email: email, password: password)
                
                if let user = user {
                    try await repository.userRepository.syncUserProfile(user: user)
                    let userProfile = try await repository.userRepository.getUserProfileFromDatabase(user: user)
                    complete( user , userProfile )
                } else {
                    complete( nil, nil )
                }
            } catch {
                print(error.localizedDescription)
                complete( nil, nil )
            }
        }
    }
    
    enum Field {
        case email ,password
    }
} 
