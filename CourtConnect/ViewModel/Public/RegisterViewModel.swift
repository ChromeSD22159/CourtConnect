//
//  RegisterViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import Supabase

@Observable class RegisterViewModel: ObservableObject {
    var repository: BaseRepository
    
    var email: String = ""
    var firstName: String = ""
    var lastName: String = "" 
    var birthday: Date = Date()
    var password: String = ""
    var repeatPassword: String = ""
    var showPassword = false
    var showRepeatPassword = false
    var focus: Field?
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    func changeFocus() {
        guard let currentFocus = focus else { return }
        switch currentFocus {
        case .email: focus = .firstName
        case .firstName: focus = .lastName
        case .lastName: focus = .password
        case .password: focus = .repeatPassword
        case .repeatPassword: focus = nil
        }
    }
    
    func signUp() async throws -> (User?, UserProfile?) {
        guard !email.isEmpty else { throw RegisterError.emailIsEmpty }
        guard !password.isEmpty else { throw RegisterError.passwordIsEmpty }
        guard !repeatPassword.isEmpty else { throw RegisterError.passwordIsEmpty }
        guard password == repeatPassword else { throw RegisterError.passwordsNotTheSame }
        
        let user = try await repository.userRepository.signUp(email: email, password: password)
        
        LocalStorageService.shared.user = user
        
        let date = Date()
        let profile = UserProfile(userId: user.id, firstName: firstName, lastName: lastName, birthday: DateUtil.dateDDMMYYYYToString(date: birthday), lastOnline: date, createdAt: date, updatedAt: date)
        
        try await repository.userRepository.sendUserProfileToBackend(profile: profile)
        return ( user, profile )
    }
    
    enum Field {
        case email, firstName, lastName, password, repeatPassword
    }
} 
