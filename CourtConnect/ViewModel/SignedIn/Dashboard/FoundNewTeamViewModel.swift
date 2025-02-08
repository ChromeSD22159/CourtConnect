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
    var uiAvatarImage: UIImage?
    
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
            if let loaded = try? await avatarItem?.loadTransferable(type: Data.self),  let uiImage = UIImage(data: loaded) {
                avatarImage =  Image(uiImage: uiImage)
                uiAvatarImage = uiImage
            } else {
                print("Failed")
            }
        }
    }
    
    func createTeam(userAccount: UserAccount, userProfile: UserProfile) async throws {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            guard !email.isEmpty && email.count > 5  else { throw InputValidationError.emailTooSmall }
            
            guard !teamName.isEmpty && teamName.count > 5 else { throw InputValidationError.teamNameTooSmall }
             
            guard headcoach.isEmpty || headcoach.count >= 5 else { throw InputValidationError.headcoachTooSmall }
            
            let generatedCode = CodeGeneratorHelper.generateCode().map { String($0) }.joined()
            let now = Date()
            
            let newTeam = Team(teamImageURL: nil, teamName: teamName, headcoach: headcoach, joinCode: generatedCode, email: email, createdByUserAccountId: userAccount.id, createdAt: now, updatedAt: now)
            let newMember = TeamMember(userAccountId: userAccount.id, teamId: newTeam.id, role: userAccount.role, createdAt: now, updatedAt: now)
            let newAdmin = TeamAdmin(teamId: newTeam.id, userAccountId: userAccount.id, role: userAccount.role, createdAt: now, updatedAt: now)
            
            if let uiAvatarImage = uiAvatarImage {
               let document: DocumentDTO = try await repository.documentRepository.uploadCachedDocument(image: uiAvatarImage, bucket: .teamFiles, teamId: newTeam.id)
                newTeam.teamImageURL = document.url
            }
            
            try await repository.teamRepository.insertTeam(newTeam: newTeam, userId: userProfile.userId)
            
            try await repository.teamRepository.insertTeamMember(newMember: newMember, userId: userProfile.userId)
            
            try await repository.teamRepository.insertTeamAdmin(newAdmin: newAdmin, userId: userProfile.userId)
            
            userAccount.teamId = newTeam.id
            
            try await repository.accountRepository.usert(item: userAccount, table: .userAccount, userId: userAccount.userId)
            try await SupabaseService.upsertWithOutResult(item: userAccount.toDTO(), table: .userAccount, onConflict: "id")
     
            try await Task.sleep(for: .seconds(1))
        } catch {
            print(error)
            throw error
        }
    }
}
