//
//  SettingViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Foundation
import Auth
import SwiftUI
import FirebaseMessaging
 
@Observable @MainActor class SettingViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
     
    var onlineUser: [UserOnlineDTO] = []
    var onlineUserCount: Int {
        self.onlineUser.count
    } 
    
    func deleteUser() {
        guard let user = user else { return }
        Task {
            do {
                _ = try await repository.userRepository.setUserOffline(userId: user.id)
                try await repository.userRepository.deleteUser(user: user)
                try await repository.userRepository.signOut()
                
                signOut()
            } catch {
                print(error.localizedDescription)
            }
        }
    } 
    
    func getAllOnlineUser() {
        Task {
            do {
                self.onlineUser = try await repository.userRepository.getOnlineUserList()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func startListeners() {
        self.listenForOnlineUserComesOnline()
        self.listenForOnlineUserGoesOffline()
    }
    
    private func listenForOnlineUserComesOnline() {
        Task {
            self.repository.userRepository.listenForOnlineUserComesOnline { result in
                switch result {
                case .success(let userList): self.onlineUser = userList
                case .failure: break
                }
            }
        }
    }
    
    private func listenForOnlineUserGoesOffline() {
        Task {
            self.repository.userRepository.listenForOnlineUserGoesOffline { result in
                switch result {
                case .success(let userList): self.onlineUser = userList
                case .failure: break
                }
            }
        }
    }
}
