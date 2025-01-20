//
//  RegisterViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation 
import FirebaseAuth

@Observable class RegisterViewModel: ObservableObject {
    var repository: Repository
    
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
    
    func signUp() async -> (User?, UserProfile?) {
        guard !email.isEmpty, !password.isEmpty else { return ( nil, nil ) }
        
        do {
            let user = try await repository.userRepository.signUp(email: email, password: password)
            let date = Date()
            let profile = UserProfile(userId: user.uid, firstName: firstName, lastName: lastName, roleString: role.rawValue, birthday: DateUtil.dateDDMMYYYYToString(date: birthday), createdAt: date, updatedAt: date, lastOnline: date)
            try await repository.userRepository.sendUserProfileToBackend(profile: profile)
            return ( user, profile )
        } catch {
            return ( nil, nil )
        }
    }
    
    enum Field {
        case email ,password
    }
}
