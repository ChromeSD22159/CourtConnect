//
//  FoundNewTeamViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import SwiftUI
import PhotosUI
import Auth

@Observable class FoundNewTeamViewModel: ObservableObject, ImagePickerProtocol, AuthProtocol {
    var repository: BaseRepository = Repository.shared
    var item: PhotosPickerItem?
    var image: Image?
    var uiImage: UIImage?
    var fileName: String = ""
    
    var teamName = ""
    var headcoach = ""
    var email = ""
    var isLoading = false
    
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    func createTeam() {
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            do {
                guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
                guard let userProfile = userProfile else { throw UserError.userAccountNotFound }
                guard !email.isEmpty && email.count > 5  else { throw InputValidationError.emailTooSmall }
                
                guard !teamName.isEmpty && teamName.count > 5 else { throw InputValidationError.teamNameTooSmall }
                 
                guard headcoach.isEmpty || headcoach.count >= 5 else { throw InputValidationError.headcoachTooSmall }
                
                let generatedCode = CodeGeneratorHelper.generateCode().map { String($0) }.joined()
                let now = Date()
                
                let newTeam = Team(teamImageURL: nil, teamName: teamName, headcoach: headcoach, joinCode: generatedCode, email: email, coachHourlyRate: nil, addStatisticConfirmedOnly: false, createdByUserAccountId: userAccount.id, createdAt: now, updatedAt: now)
                let newMember = TeamMember(userAccountId: userAccount.id, teamId: newTeam.id, shirtNumber: nil, position: "", role: userAccount.role, createdAt: now, updatedAt: now)
                let newAdmin = TeamAdmin(teamId: newTeam.id, userAccountId: userAccount.id, role: userAccount.role, createdAt: now, updatedAt: now)
                
                if let uiImage = uiImage {
                    let document: DocumentDTO = try await repository.documentRepository.uploadCachedDocument(image: uiImage, fileName: "\(teamName)_image", info: "", bucket: .teamFiles, teamId: newTeam.id)
                    newTeam.teamImageURL = document.url
                }
                
                try await repository.teamRepository.insertTeam(newTeam: newTeam, userId: userProfile.userId)
                
                try await repository.teamRepository.insertTeamMember(newMember: newMember, userId: userProfile.userId)
                
                try await repository.teamRepository.insertTeamAdmin(newAdmin: newAdmin, userId: userProfile.userId)
                
                userAccount.teamId = newTeam.id
                
                try repository.accountRepository.usert(item: userAccount, table: .userAccount, userId: userAccount.userId)
                try await SupabaseService.upsertWithOutResult(item: userAccount.toDTO(), table: .userAccount, onConflict: "id")
         
                try await Task.sleep(for: .seconds(1)) 
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
}
