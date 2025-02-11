//
//  DocumentSheetButtonViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import PhotosUI 

@Observable class DocumentSheetButtonViewModel: Sheet, ImagePickerProtocol {
    var isSheet = false
    var isLoading = false
    var animateOnAppear = false
    var item: PhotosPickerItem?
    var image: Image?
    var uiImage: UIImage?
    var userAccount: UserAccount?
    var fileName: String = ""
    let repository: BaseRepository
    
    @MainActor init(userAccount: UserAccount? = nil) {
        self.userAccount = userAccount
        self.repository = Repository.shared
    }
    
    func toggleSheet() {
        isSheet.toggle()
    }
    
    private func toggleAnimation() {
        isLoading.toggle()
    }
    
    @MainActor func saveDocuemt() {
        Task {
            self.toggleAnimation()
            
            defer { self.toggleAnimation() }
            
            do {
                guard let userAccount = userAccount else { throw UserError.userIdNotFound }
                guard let teamId = userAccount.teamId else { throw UserError.userAccountNotFound }
                guard let image = uiImage else { throw UserError.userAccountNotFound }
                guard fileName.count >= 5 else { throw DocumentError.fileNameToShot }
                
                let document: DocumentDTO = try await repository.documentRepository.uploadCachedDocument(image: image, fileName: fileName, bucket: .teamFiles, teamId: teamId)
 
                repository.documentRepository.insert(document: document, userId: userAccount.userId)
                
                try await Task.sleep(for: .seconds(2))
                
                print("local: \(try repository.documentRepository.getDocuments(for: teamId).count)")
                self.toggleSheet()
                disappear()
            } catch {
                print(error)
            }
        }
    }
    
    func disappear() {
        self.resetImage()
        self.fileName = ""
    }
}
