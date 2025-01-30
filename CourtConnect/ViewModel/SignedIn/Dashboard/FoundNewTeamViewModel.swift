//
//  FoundNewTeamViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI
import PhotosUI

@Observable class FoundNewTeamViewModel: ObservableObject {
    var avatarItem: PhotosPickerItem?
    var avatarImage: Image?
    
    var teamName = ""
    var headcoach = ""
    var email = ""
    var isLoading = false
     
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    func changeImage() {
        Task {
            if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                avatarImage = loaded
            } else {
                print("Failed")
            }
        }
    }
    
    func createTeam(userAccount: UserAccount, userProfile: UserProfile) async throws {
        do {
            guard !email.isEmpty && email.count > 5  else { throw InputValidationError.emailTooSmall }
            
            guard !teamName.isEmpty && teamName.count > 5 else { throw InputValidationError.teamNameTooSmall }
             
            guard headcoach.isEmpty || headcoach.count >= 5 else { throw InputValidationError.headcoachTooSmall }

            let generatedCode = CodeGeneratorHelper.generateCode().map { String($0) }.joined()
            let now = Date()
            let newTeam = Team(teamName: teamName, createdBy: userProfile.fullName, headcoach: headcoach, joinCode: generatedCode, email: email, createdAt: now, updatedAt: now)
            let newMember = TeamMember(userAccountId: userAccount.id, teamId: newTeam.id, role: userAccount.role, createdAt: now, updatedAt: now)
            let newAdmin = TeamAdmin(teamId: newTeam.id, userAccountId: userAccount.id, role: userAccount.role, createdAt: now, updatedAt: now)
             
            isLoading = true
            
            try await repository.teamRepository.insertTeam(newTeam: newTeam, userId: userProfile.userId)
            
            try await repository.teamRepository.insertTeamMember(newMember: newMember, userId: userProfile.userId)
            
            try await repository.teamRepository.insertTeamAdmin(newAdmin: newAdmin, userId: userProfile.userId)
            
            userAccount.teamId = newTeam.id
            
            try await Task.sleep(for: .seconds(1))
            isLoading = false
        } catch {
            isLoading = false
            throw error
        }
    }
}
