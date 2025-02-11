//
//  RegisterViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import Supabase
import Auth

@Observable class RegisterViewModel: ObservableObject, SyncHistoryProtocol, AuthProtocol {
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var repository: BaseRepository = Repository.shared
    var isfetching: Bool = false
    
    var email: String = ""
    var firstName: String = ""
    var lastName: String = "" 
    var birthday: Date = Date()
    var password: String = ""
    var repeatPassword: String = ""
    var showPassword = false
    var showRepeatPassword = false
    var focus: Field?
    var userRole: UserRole = .player
    var position: BasketballPosition = .center
    var isLoadingAnimation = false
    var isOnboardingSheet = false
    
    var containerSize: CGSize = .zero
    
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
    
    func signUp() {
        isLoadingAnimation.toggle()
          
        Task {
            defer { isLoadingAnimation.toggle() }
            do {
                try await Task.sleep(for: .seconds(1))
                guard !email.isEmpty else { throw RegisterError.emailIsEmpty }
                guard !password.isEmpty else { throw RegisterError.passwordIsEmpty }
                guard !repeatPassword.isEmpty else { throw RegisterError.passwordIsEmpty }
                guard password == repeatPassword else { throw RegisterError.passwordsNotTheSame }
                
                let user = try await repository.userRepository.signUp(email: email, password: password)
                 
                let date = Date()
                let profile = UserProfile(userId: user.id, firstName: firstName, lastName: lastName, birthday: DateUtil.dateDDMMYYYYToString(date: birthday), lastOnline: date, createdAt: date, updatedAt: date)
                let account = UserAccount(userId: user.id, teamId: nil, position: position.rawValue, role: userRole.rawValue, displayName: userRole.rawValue, createdAt: Date(), updatedAt: Date())
                
                try await repository.accountRepository.sendToBackend(item: account)
                try await repository.userRepository.sendUserProfileToBackend(profile: profile)
                
                /// SAVE CURRENT USERS
                LocalStorageService.shared.user = user
                LocalStorageService.shared.userAccountId = account.id.uuidString
                
                isLoadingAnimation.toggle()
                
                inizializeAuth()
                
                try await Task.sleep(for: .seconds(1))
                 
                if userProfile != nil {
                    isOnboardingSheet.toggle()
                }
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
     
    func onDismissOnBoarding(userProfile: UserProfile?) async {
        do {
            guard let userProfile = userProfile, userProfile.onBoardingAt == nil else { return }
            userProfile.onBoardingAt = Date()
            userProfile.updatedAt = Date()
            
            try repository.userRepository.container.mainContext.save()
            
            try await repository.userRepository.sendUserProfileToBackend(profile: userProfile)
            
            try await syncAllTablesAfterLastSync(userId: userProfile.userId)
            
            if await !NotificationService.getAuthStatus() {
                await NotificationService.request()
            }
        } catch {
            print(error)
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
        case email, firstName, lastName, password, repeatPassword
    }
}
