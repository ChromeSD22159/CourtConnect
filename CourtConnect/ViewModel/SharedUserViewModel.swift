//
//  UserViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Supabase
import Foundation
import SwiftUI

@Observable
class SharedUserViewModel: ObservableObject {
    var user: User? = nil
    var userProfile: UserProfile? = nil
    var showOnBoarding = false
    var editProfile: UserProfile = UserProfile(userId: "", firstName: "", lastName: "", roleString: UserRole.player.rawValue, birthday: "", createdAt: Date(), updatedAt: Date())
    var onlineUser: [UserOnline] = []
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
    
    private var userRepository: UserRepository {
        self.repository.userRepository
    }
    
    init(repository: Repository) {
        self.repository = repository
        if repository.userRepository.type == .preview {
            let cal = Calendar.current 
            let createdAt = cal.date(byAdding: .day, value: -10, to: Date())!
            let updatedAt = cal.date(byAdding: .day, value: -1, to: Date())!
            self.userProfile = UserProfile(userId: "", firstName: "", lastName: "", roleString: UserRole.player.rawValue, birthday: "", createdAt: createdAt, updatedAt: updatedAt)
        }
    }
    
    func onAppDashboardAppear() {
        if userProfile == nil {
            showOnBoarding.toggle()
        } else {
            userIsOnline()
        }
    }
    
    func startListeners() {
        self.listenForOnlineUserComesOnline()
        self.listenForOnlineUserGoesOffline() 
    }
    
    func setEditUserProfile(userProfile: UserProfile) {
        self.editProfile = userProfile
    }
    
    func resetEditUserProfile() {
        guard let uid = self.user?.id.uuidString else { return }
        self.editProfile = UserProfile(userId: uid, firstName: "", lastName: "", roleString: UserRole.player.rawValue, birthday: "")
    }
    
    func saveUserProfile() {
        guard
            let user = user,
            !editProfile.firstName.isEmpty,
            !editProfile.lastName.isEmpty,
            !editProfile.roleString.isEmpty
        else {
            return
        }
        
        editProfile.userId = user.id.uuidString
        editProfile.updatedAt = Date()
        
        Task {
            do { 
                try await self.userRepository.sendUserProfileToBackend(profile: editProfile)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                if let user = user {
                    try await userRepository.signOut(user: user)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func userIsOnline() {
        guard let userProfile = userProfile else { return }
        userProfile.lastOnline = Date()
        Task {
            try await self.userRepository.sendUserProfileToBackend(profile: userProfile)
        }
    }
    
    func isAuthendicated() {
        Task {
            await repository.userRepository.isAuthendicated { (user: User?, userProfile: UserProfile?) in
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
        self.showOnBoarding.toggle()
    }
    
    func setUserOnline() {
        guard let user = user, let userProfile = userProfile else { return }
        Task {
            do {
                let result = try await userRepository.setUserOnline(user: user, userProfile: userProfile)
                
                if result {
                    print("User wurde Online gesetzt!")
                } else {
                    print("User konnte nicht Online gesetzt werden!")
                }
                
                self.onlineUser = try await userRepository.getOnlineUserList()
            }
            catch { print(error) }
        }
    }
    
    func setUserOffline() {
        guard let user = user else { return }
        Task {
            do {
                let result = try await userRepository.setUserOffline(user: user)
                
                if result {
                    print("User wurde Offline gesetzt!")
                } else {
                    print("User konnte nicht Offline gesetzt werden!")
                }
            }
            catch { print(error) }
        }
    } 
    
    func listenForOnlineUserComesOnline() {
        Task {
            await repository.userRepository.listenForOnlineUserComesOnline() { onlineUserList in
                self.onlineUser = onlineUserList 
            }
        }
    }
    
    func listenForOnlineUserGoesOffline() {
        Task {
            
            await repository.userRepository.listenForOnlineUserGoesOffline() { onlineUserList in
                self.onlineUser = onlineUserList
            }
        }
    } 
}
