//
//  UserViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Supabase
import Foundation

@Observable class SharedUserViewModel: ObservableObject {
    var user: User? = nil
    var userProfile: UserProfile? = nil
    
    let userRepository: UserRepository
    
    var editProfile: UserProfile
    
    init(repository: Repository) {
        self.userRepository = repository.userRepository
        self.editProfile = UserProfile(firstName: "", lastName: "", birthday: Date(), roleString: UserRole.player.rawValue)
    }
    
    func setEditUserProfile(userProfile: UserProfile) {
        self.editProfile = userProfile
    }
    
    func resetEditUserProfile() {
        self.editProfile = UserProfile(firstName: "", lastName: "", birthday: Date(), roleString: UserRole.player.rawValue)
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
        
        editProfile.userId = user.id
        
        Task {
            do { 
                try await self.userRepository.sendUserProfileToBackend(profile: editProfile)
                
                self.userProfile = try await self.userRepository.getUserProfileFromDatabase(user: user) 
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
}
