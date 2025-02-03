//
//  DocumentSheetButtonViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import PhotosUI
import Storage
import Combine
 
@Observable class DocumentSheetButtonViewModel: Sheet {
    var isSheet = false
    var isLoading = false
    var animateOnAppear = false
    var item: PhotosPickerItem?
    var image: Image?
    var uiImage: UIImage?
    var userAccount: UserAccount?
    
    let repository: BaseRepository
    
    @MainActor init(userAccount: UserAccount? = nil) {
        self.userAccount = userAccount
        self.repository = Repository.shared
    }
    
    func toggleSheet() {
        isSheet.toggle()
    }
    
    func setImage() {
        Task {
            if let imageData = try? await item?.loadTransferable(type: Data.self), let uiImage = UIImage(data: imageData) {
                if uiImage.size.height > uiImage.size.width {
                    let scaledImage = uiImage.scaleToHeight(400)
                    self.uiImage = scaledImage
                    self.image = Image(uiImage: scaledImage)
                } else {
                    let scaledImage = uiImage.scaleToHeight(400)
                    self.uiImage = scaledImage
                    self.image = Image(uiImage: scaledImage)
                }
            } else {
                print("Failed to convert Image to UIImage")
            }
        }
    }
    
    private func toggleAnimation() {
        isLoading.toggle()
    }
    
    private func resetImage() {
        image = nil
    }
    
    @MainActor func saveDocuemt() {
        Task {
            self.toggleAnimation()
            
            defer { self.toggleAnimation() }
            
            do {
                guard let userAccount = userAccount else { throw UserError.userIdNotFound }
                guard let teamId = userAccount.teamId else { throw UserError.userAccountNotFound }
                guard let image = uiImage else { throw UserError.userAccountNotFound }
                
                let document: DocumentDTO = try await repository.documentRepository.uploadCachedDocument(image: image, bucket: .teamFiles, teamId: teamId)
 
                repository.documentRepository.insert(document: document)
                
                try await Task.sleep(for: .seconds(2))
                
                print("local: \(try repository.documentRepository.getDocuments(for: teamId).count)")
                
                self.toggleSheet()
                self.resetImage()
            } catch {
                print(error)
            }
        }
    }
}  
