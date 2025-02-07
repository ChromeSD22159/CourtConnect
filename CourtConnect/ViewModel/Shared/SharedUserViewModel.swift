//
//  UserViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation
import SwiftUI
import FirebaseMessaging
import Supabase 
 
@Observable
@MainActor
class SharedUserViewModel: ObservableObject {
    var user: User? = LocalStorageService.shared.user
    var userProfile: UserProfile?
    var currentAccount: UserAccount?
    var isOnboardingSheet = false
    var isEditSheet = false
    var showDeleteConfirmMenu = false
    var editProfile: UserProfile = UserProfile(userId: UUID(), firstName: "", lastName: "", birthday: "", createdAt: Date(), updatedAt: Date())
    var onlineUser: [UserOnlineDTO] = []
    var accounts: [UserAccount] = []
    var isCreateRoleSheet = false 
    var onlineUserCount: Int {
        self.onlineUser.count
    }
    var birthBinding: Binding<Date> {
        Binding {
            if let date = DateUtil.stringToDateDDMMYYYY(string: self.editProfile.birthday) {
                return date
            } else {
                return Date()
            }
        } set: { updatedDate in
            self.editProfile.birthday = DateUtil.dateDDMMYYYYToString(date: updatedDate)
        }
    }

    let repository: BaseRepository
    
    @MainActor init(repository: BaseRepository) {
        self.repository = repository
    }
    
    func startListeners() {
        self.listenForOnlineUserComesOnline()
        self.listenForOnlineUserGoesOffline() 
    }
     
    func signOut() {
        Task {
            do {
                try await self.repository.userRepository.signOut()
                self.setCurrentAccount(newAccount: nil)
                
                user = nil
                userProfile = nil
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isAuthendicated(syncServiceViewModel: SyncServiceViewModel) async {
        do {
            if let user = await self.repository.userRepository.isAuthendicated() {
                
                await syncAllTables(syncServiceViewModel: syncServiceViewModel)
                
                if let responseUserProfile = try repository.userRepository.getUserProfileFromDatabase(userId: user.id) {
                    withAnimation {
                        self.user = user
                        self.userProfile = responseUserProfile
                    }
                }
                
                getCurrentAccount(userId: user.id)
            }
        } catch {
            print(error)
        }
    }
    
    func openEditProfileSheet() {
        guard let profile = userProfile else { return }
        self.setEditUserProfile(userProfile: profile)
        self.isEditSheet.toggle()
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
                
                self.onlineUser = try await self.repository.userRepository.getOnlineUserList()
                
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
     
    func getAllOnlineUser() {
        Task {
            do {
                self.onlineUser = try await repository.userRepository.getOnlineUserList()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func changeOnlineStatus(phase: ScenePhase) {
        if phase == .active {
            setUserOnline()
        } else if phase == .background {
            setUserOffline()
        }
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
    
    func showOnBoardingIfNeverShowBefore() {
        if userProfile?.onBoardingAt == nil {
            isOnboardingSheet.toggle()
        }
    }
    
    func syncAllTables(syncServiceViewModel: SyncServiceViewModel) async {
        do {
            guard let user = user else { throw UserError.userIdNotFound }
            
            if userProfile?.onBoardingAt != nil {
                print("FETCH WHEN USER AND ONBOARING ALREADY IS SHOWN")
                try await syncServiceViewModel.fetchAllTables(userId: user.id)
            } else {
                print("FETCH WHEN USER")
                try await syncServiceViewModel.fetchAllTables(userId: user.id)
            }
        } catch { 
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
    }
    
    func onDismissOnBoarding(syncServiceViewModel: SyncServiceViewModel) {
        guard let userProfile = userProfile, userProfile.onBoardingAt == nil else { return }
        Task {
            do {
                userProfile.onBoardingAt = Date()
                userProfile.updatedAt = Date()
                try repository.userRepository.container.mainContext.save()
                
                try await repository.userRepository.sendUserProfileToBackend(profile: userProfile) 
                
                await syncAllTables(syncServiceViewModel: syncServiceViewModel)
                
                if await !NotificationService.getAuthStatus() {
                    await NotificationService.request()
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - UserProfile Methodes
    func saveUserProfile() {
        guard
            let user = self.user,
            !editProfile.firstName.isEmpty,
            !editProfile.lastName.isEmpty
        else {
            return
        }
        
        editProfile.userId = user.id
        editProfile.updatedAt = Date()
        
        Task {
            do {
                try await self.repository.userRepository.sendUserProfileToBackend(profile: editProfile) 

                self.setUserOffline()
                self.setUserOnline()
            } catch {
                print("UserVM: " + error.localizedDescription)
            }
        }
    }
    
    func resetEditUserProfile() {
        guard let user = user else { return }
        self.editProfile = UserProfile(userId: user.id, firstName: "", lastName: "", birthday: "", createdAt: Date(), updatedAt: Date())
    }
    
    func setEditUserProfile(userProfile: UserProfile) {
        self.editProfile = userProfile
    }
    
    // MARK: - UserAccount Methodes
    func deleteUser() {
        guard let user = user else { return }
        Task {
            do {
                
                try await repository.userRepository.deleteUser(user: user)
                try await repository.userRepository.signOut()
                
                self.user = nil
                self.userProfile = nil
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCurrentAccount(userId: UUID) {
        do {
            if let id = LocalStorageService.shared.userAccountId {
                let userAccount = try repository.accountRepository.getAccount(id: UUID(uuidString: id)!) // nil
                currentAccount = userAccount
            } else {
                if let userAccount = try repository.accountRepository.getAllAccounts(userId: userId).first {
                    currentAccount = userAccount
                    
                    LocalStorageService.shared.userAccountId = userAccount.id.uuidString
                }
            }
        } catch {
            print(error)
        }
    }
    
    func setCurrentAccount(newAccount: UserAccount?) {
        self.currentAccount = newAccount
        LocalStorageService.shared.userAccountId = newAccount?.id.uuidString
    }
    
    func setRandomAccount() throws {
        guard let userId = user?.id else { return }
        let newAccountList = try repository.accountRepository.getAllAccounts(userId: userId)
        self.accounts = newAccountList
        currentAccount = newAccountList.first
        LocalStorageService.shared.userAccountId = currentAccount?.id.uuidString
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
                
                self.getAllUserAccountsFromDatabase()
            } catch {
                self.getAllUserAccountsFromDatabase()
            }
        }
    }
    
    func getAllUserAccountsFromDatabase() {
        guard let userId = user?.id else { return }
        do {
            self.accounts = try repository.accountRepository.getAllAccounts(userId: userId)
        } catch {
            print(error)
        }
    }
    
    func userHasBothAccounts(role1: String = UserRole.player.rawValue, role2: String = UserRole.trainer.rawValue) -> Bool {
        let rolesSet = Set(accounts.map { $0.role })
        return rolesSet.contains(role1) && rolesSet.contains(role2)
    }
}
