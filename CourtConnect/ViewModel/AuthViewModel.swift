//
//  AuthViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation
import Auth
import FirebaseMessaging
import SwiftUI
import WidgetKit

@MainActor @Observable class AuthViewModel: AuthProtocol, SyncHistoryProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var userAccounts: [UserAccount] = []
    var currentTeam: Team?
    var isfetching: Bool = false
    var isSlashScreen = true
     
    func getAccounts() {
        self.inizializeAuth()
    }
    
    func importAccountsAfterLastSyncFromBackend() {
        guard let userId = user?.id else { return }
        Task {
            do {
                let lastSync = try repository.syncHistoryRepository.getLastSyncDate(for: .userAccount, userId: userId).timestamp
                let result = try await repository.accountRepository.fetchFromServer(after: lastSync)
                
                for account in result {
                    try repository.accountRepository.usert(item: account.toModel(), table: .userAccount, userId: userId)
                }
                
                try self.repository.syncHistoryRepository.insertLastSyncTimestamp(for: .userAccount, userId: userId)
                
                self.userAccounts = try repository.accountRepository.getAllAccounts(userId: userId)
            } catch {
                self.userAccounts = try repository.accountRepository.getAllAccounts(userId: userId)
            }
        }
    } 
    
    func setUserOnline() {
        guard let user = user, let userProfile = userProfile else { return }
         
        Task {
            do {
                userProfile.lastOnline = Date()
                if let fcmToken = try? await Messaging.messaging().token() {
                    userProfile.fcmToken = fcmToken
                }
                
                _ = try await self.repository.userRepository.setUserOnline(userId: user.id, userProfile: userProfile)
                
                try await self.repository.userRepository.sendUserProfileToBackend(profile: userProfile)
            } catch { print(error) }
        }
    }
    
    func setUserOffline() {
        guard let user = user else { return }
        Task {
            do {
                _ = try await self.repository.userRepository.setUserOffline(userId: user.id)
            } catch { print(error) }
        }
    }
    
    func onScenePhaseChange(newValue: ScenePhase) {
        switch newValue {
        case .background:
            WidgetCenter.shared.reloadAllTimelines()
        case .inactive: break
        case .active: break
        @unknown default: break
        }
    }
    
    func loadRocketSimConnect() {
        #warning("RocketSim Connect successfully linked")
        #if DEBUG
        guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
            print("Failed to load linker framework")
            return
        }
        print("RocketSim Connect successfully linked")
        #endif
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
}
