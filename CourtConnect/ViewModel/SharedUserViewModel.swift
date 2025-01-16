//
//  UserViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Supabase
import Foundation
import SwiftUI

@Observable class SharedUserViewModel: ObservableObject {
    var user: User? = nil
    var userProfile: UserProfile? = nil
    var showOnBoarding = false
    var editProfile: UserProfile
    
    let repository: Repository
    
    private var userRepository: UserRepository {
        self.repository.userRepository
    }
    
    init(repository: Repository) {
        self.repository = repository
        if repository.userRepository.type == .preview {
            let cal = Calendar.current
            
            let birthday = cal.date(byAdding: .year, value: -1, to: Date())
            let createdAt = cal.date(byAdding: .day, value: -10, to: Date())
            let updatedAt = cal.date(byAdding: .day, value: -1, to: Date())
            self.userProfile = UserProfile(userId: "", firstName: "", lastName: "", birthday: birthday!, roleString: UserRole.player.rawValue, createdAt: createdAt!, updatedAt: updatedAt!)
        }
        self.editProfile = UserProfile(userId: "", firstName: "", lastName: "", birthday: Date(), roleString: UserRole.player.rawValue, createdAt: Date(), updatedAt: Date())
    }
    
    func onAppDashboardAppear() {
        if userProfile == nil {
            showOnBoarding.toggle()
        } else {
            userIsOnline()
        }
    }
    
    func setEditUserProfile(userProfile: UserProfile) {
        self.editProfile = userProfile
    }
    
    func resetEditUserProfile() {
        guard let uid = self.user?.id.uuidString else { return }
        self.editProfile = UserProfile(userId: uid, firstName: "", lastName: "", birthday: Date(), roleString: UserRole.player.rawValue)
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
}
