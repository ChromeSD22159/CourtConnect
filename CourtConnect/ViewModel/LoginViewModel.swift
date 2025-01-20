//
//  LoginViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import FirebaseAuth

@Observable class LoginViewModel: ObservableObject {
    var repository: Repository
    
    var email: String = ""
    var password: String = ""
    var showPassword = false
    var keepSignededIn = true
    var focus: Field?
     
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
    
    func signIn() async throws -> (User?, UserProfile?) {
        guard !email.isEmpty, !password.isEmpty else {
            return (nil , nil)
        }
        
        let user = try await repository.userRepository.signIn(email: email, password: password)
         
        try await repository.userRepository.syncUserProfile(userId: user.uid)
        let userProfile = try await repository.userRepository.getUserProfileFromDatabase(userId: user.uid)
        return ( user , userProfile )
    }
    
    enum Field {
        case email ,password
    }
} 
