//
//  LoginViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import Supabase

@Observable class LoginViewModel: ObservableObject {
    var repository: BaseRepository
    
    var email: String = ""
    var password: String = ""
    var showPassword = false
    var keepSignededIn = true
    var focus: Field?
    var error: Error?
    
    init(repository: BaseRepository) {
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
        do {
            guard !email.isEmpty else {
                throw LoginError.emailIsEmpty
            }
                    
            guard !password.isEmpty else {
                throw LoginError.passwordIsEmpty
            }
            
            let user = try await repository.userRepository.signIn(email: email, password: password)
             
            if keepSignededIn {
                LocalStorageService.shared.user = user
            }
            
            try await repository.userRepository.syncUserProfile(userId: user.id)
            let userProfile = try await repository.userRepository.getUserProfileFromDatabase(userId: user.id)
            return ( user , userProfile )
        } catch {
            throw error
        }
    }
    
    enum Field {
        case email ,password
    }
} 
