//
//  LoginViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import Supabase
import Auth

@Observable @MainActor class LoginViewModel: ObservableObject, SyncHistoryProtocol, AuthProtocol {
    var repository: BaseRepository = Repository.shared
    
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
     
    var isfetching: Bool = false
    
    var email: String = ""
    var password: String = ""
    var showPassword = false
    var keepSignededIn = true
    var focus: Field?
    var error: Error?
    var isLoadingAnimation: Bool = false
    
    var containerSize: CGSize = .zero
    
    func changeFocus() {
        guard let currentFocus = focus else { return }
        switch currentFocus {
        case .email: focus = .password
        case .password: focus = nil
        }
    }
    
    func signIn() async {
        isLoadingAnimation.toggle()
        defer {
            isLoadingAnimation.toggle()
        }
        do {
            try await Task.sleep(for: .seconds(1))
            
            guard !email.isEmpty else {
                throw LoginError.emailIsEmpty
            }
                    
            guard !password.isEmpty else {
                throw LoginError.passwordIsEmpty
            }
            
            let user = try await repository.userRepository.signIn(email: email, password: password)
            let userAccounts = try repository.accountRepository.getAllAccounts(userId: user.id)
             
            LocalStorageService.shared.user = user
            LocalStorageService.shared.userAccountId = userAccounts.first?.id.uuidString 
            
            try await repository.userRepository.syncUserProfile(userId: user.id)
            
            try await syncAllTables(userId: user.id)
            
            try await Task.sleep(for: .seconds(1)) 
        } catch {
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
    }
    
    func fetchDataFromRemote() {
        Task {
            do {
                if let userId = user?.id {
                    try await syncAllTables(userId: userId)
                }
            } catch {
                print(error)
            }
        }
    }
    
    enum Field {
        case email ,password
    }
} 
