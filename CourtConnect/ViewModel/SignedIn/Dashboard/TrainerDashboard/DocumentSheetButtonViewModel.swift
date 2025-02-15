//
//  DocumentSheetButtonViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import PhotosUI 
import Auth

@Observable class DocumentSheetButtonViewModel: Sheet, ImagePickerProtocol, AuthProtocol {
    var repository: BaseRepository = Repository.shared
    
    var user: User?
    var userProfile: UserProfile?
    var userAccount: UserAccount?
    var currentTeam: Team?
    
    var isSheet = false
    var isLoading = false
    var animateOnAppear = false
    var item: PhotosPickerItem?
    var image: Image?
    var uiImage: UIImage?
    var fileName: String = ""
    
    init() {
        inizializeAuth()
    }
    
    func toggleSheet() {
        isSheet.toggle()
    }
    
    private func toggleAnimation() {
        isLoading.toggle()
    }
    
    func isAuthendicated() async {
        let _ = await repository.userRepository.isAuthendicated()
    } 
    
    @MainActor func saveDocuemtThrows() async throws {
        self.toggleAnimation()
        
        defer { self.toggleAnimation() }
        
        do {
            guard let userAccount = userAccount else { throw UserError.userIdNotFound }
            guard let teamId = userAccount.teamId else { throw UserError.userAccountNotFound }
            guard let image = uiImage else { throw UserError.userAccountNotFound }
            guard fileName.count >= 5 else { throw DocumentError.fileNameToShot }
            
            // TODO: 
            let document: DocumentDTO = try await repository.documentRepository.uploadCachedDocument(image: image, fileName: fileName, info: "", bucket: .teamFiles, teamId: teamId)

            repository.documentRepository.insert(document: document, userId: userAccount.userId)
            
            try await Task.sleep(for: .seconds(2))
            
            print("local: \(try repository.documentRepository.getDocuments(for: teamId).count)")
            self.toggleSheet()
            disappear()
        } catch {
            throw error
        }
    }
    
    func disappear() {
        self.resetImage()
        self.fileName = ""
    }
}
