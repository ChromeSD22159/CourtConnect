//
//  AuthProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Foundation
import Auth

@MainActor protocol AuthProtocol: ObservableObject {
    var repository: BaseRepository { get set }
    var user: User? { get set }
    var userAccount: UserAccount? { get set }
    var userProfile: UserProfile? { get set }
}

extension AuthProtocol {
    func getUser() {
        user = repository.authRepository.getUser()
    }
    
    func getUserAccount() {
        do {
            userAccount = try repository.authRepository.getcurrentUserAccount()
        } catch {
            print(error)
        }
    }
    
    func getUserProfile() {
        do {
            userProfile = try repository.authRepository.getCurrentUserProfile()
        } catch {
            print(error)
        }
    }
    
    func signOut() {
        Task {
            do {
                try await self.repository.userRepository.signOut()
                LocalStorageService.shared.userAccountId = nil
                LocalStorageService.shared.user = nil
                userAccount = nil
                userProfile = nil
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
