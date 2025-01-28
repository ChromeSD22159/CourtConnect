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
    var showOnBoarding = false
    var showUserEditSheet = false
    var showDeleteConfirmMenu = false
    var editProfile: UserProfile = UserProfile(userId: UUID(), firstName: "", lastName: "", birthday: "", createdAt: Date(), updatedAt: Date())
    var onlineUser: [UserOnlineDTO] = []
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

    let repository: Repository
    
    @MainActor init(repository: Repository) {
        self.repository = repository
    }
    
    func startListeners() {
        self.listenForOnlineUserComesOnline()
        self.listenForOnlineUserGoesOffline() 
    }
    
    func setEditUserProfile(userProfile: UserProfile) {
        self.editProfile = userProfile
    }
    
    func resetEditUserProfile() {
        guard let user = user else { return }
        self.editProfile = UserProfile(userId: user.id, firstName: "", lastName: "", birthday: "", createdAt: Date(), updatedAt: Date())
    }
    
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
                
                try await self.repository.syncHistoryRepository.insertUpdateTimestampTable(for: .userProfile, userId: user.id)
                
                self.setUserOffline()
                self.setUserOnline()
            } catch {
                print("UserVM: " + error.localizedDescription)
            }
        }
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
    
    func isAuthendicated() {
        Task {
            if let user = await self.repository.userRepository.isAuthendicated(),
               let userProfile = try self.repository.userRepository.getUserProfileFromDatabase(userId: user.id) {
                
                withAnimation {
                    self.user = user
                    self.userProfile = userProfile
                }
            }
        }
    }
    
    func openEditProfileSheet() {
        guard let profile = userProfile else { return }
        self.setEditUserProfile(userProfile: profile)
        self.showUserEditSheet.toggle()
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
    
    func deleteUserAccount() {
        guard let user = user else { return }
        Task {
            do {
                
                try await repository.userRepository.deleteUserAccount(user: user)
                try await repository.userRepository.signOut()
                
                self.user = nil
                self.userProfile = nil
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func setCurrentAccount(newAccount: UserAccount?) {
        self.currentAccount = newAccount
        LocalStorageService.shared.userAccountId = newAccount?.id.uuidString
        isAuthendicated()
    }
    
    func getCurrentAccount() {
        guard let id = LocalStorageService.shared.userAccountId else { return }
        do { 
            currentAccount = try repository.accountRepository.getAccount(id: UUID(uuidString: id)!)
        } catch {
            print(error.localizedDescription)
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
    
    func setOnBooarding() {
        userProfile?.onBoardingAt = Date()
    }
    
    func onDismissOnBoarding(onComplete: @escaping (UUID?, Error?) -> Void) {
        Task {
            do {
                setOnBooarding()
                guard let userId = user?.id else { throw UserError.userIdNotFound }
                onComplete(userId, nil)
            } catch {
                onComplete(nil, error)
            }
        }
    }
}
