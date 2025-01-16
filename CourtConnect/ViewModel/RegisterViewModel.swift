//
//  RegisterViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import Supabase

@Observable class RegisterViewModel: ObservableObject {
    var userRepository: UserRepository
    
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var role: UserRole = .player
    var birthday: Date = Date()
    var password: String = ""
    var repeatPassword: String = ""
    var showPassword = false
    var showRepeatPassword = false
    var focus: Field? = nil
    
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func changeFocus() {
        guard let currentFocus = focus else { return }
        switch currentFocus {
            case .email: focus = .password
            case .password: focus = nil
        }
    }
    
    func signUp(complete: (User?, UserProfile?) -> Void) async {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        do {
            let user = try await userRepository.signUp(email: email, password: password)
            
            // TODO: GUARD PROFILE DATA
            let profile = UserProfile(firstName: firstName, lastName: lastName, birthday: birthday, roleString: role.rawValue)
            try await userRepository.sendUserProfileToBackend(profile: profile)
            complete( user, profile )
        } catch {
            print(error.localizedDescription)
            complete( nil, nil )
        }
    }
    
    enum Field {
        case email ,password
    }
}
