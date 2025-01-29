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
    
    func createTeam(userAccount: UserAccount, userProfile: UserProfile) {
        guard
            !email.isEmpty && headcoach.count > 3,
            !teamName.isEmpty && teamName.count > 3,
            !headcoach.isEmpty && headcoach.count > 3
        else {
           return
        }
        
        let generatedCode = CodeGeneratorHelper.generateCode().map { String($0) }.joined()
        let now = Date()
        let newTeam = Team(teamName: teamName, createdBy: userProfile.fullName, headcoach: "", joinCode: generatedCode, email: "", createdAt: now, updatedAt: now)
        let newMember = TeamMember(userId: userAccount.id, teamId: newTeam.id, role: userAccount.role, createdAt: now, updatedAt: now)
        let newAdmin = TeamAdmin(teamId: newTeam.id, userId: userAccount.id, role: userAccount.role, createdAt: now, updatedAt: now)
         
        Task {
            isLoading.toggle()
            
            try await repository.teamRepository.insertTeam(newTeam: newTeam)
            try await repository.syncHistoryRepository.insertLastSyncTimestamp(for: .team, userId: userAccount.userId)
            
            try await repository.teamRepository.insertTeamMember(newMember: newMember)
            try await repository.syncHistoryRepository.insertLastSyncTimestamp(for: .team, userId: userAccount.userId)
            
            try await repository.teamRepository.insertTeamAdmin(newAdmin: newAdmin)
            try await repository.syncHistoryRepository.insertLastSyncTimestamp(for: .team, userId: userAccount.userId)
            
            try await Task.sleep(for: .seconds(3))
            isLoading.toggle()
        }
    }
}
