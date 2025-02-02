//
//  DocumentSheetButtonViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import PhotosUI
 
@Observable class DocumentSheetButtonViewModel: Sheet {
    var isSheet = false
    var isLoading = false
    var animateOnAppear = false
    var item: PhotosPickerItem?
    var image: Image?
    var userAccount: UserAccount?
    
    init(userAccount: UserAccount? = nil) {
        self.userAccount = userAccount
    }
    
    func toggleSheet() {
        isSheet.toggle()
    }
    
    func setImage() {
        Task {
            if let imageData = try? await item?.loadTransferable(type: Data.self), let uiImage = UIImage(data: imageData) {
                if uiImage.size.height > uiImage.size.width {
                    let scaledImage = uiImage.scaleToHeight(400)
                    image = Image(uiImage: scaledImage)
                } else {
                    let scaledImage = uiImage.scaleToHeight(400)
                    image = Image(uiImage: scaledImage)
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
    
    func saveDocuemt() {
        Task {
            self.toggleAnimation()
            
            defer { self.toggleAnimation() }
            
            do {
                guard let userAccount = userAccount else { throw UserError.userIdNotFound }
                guard let teamId = userAccount.teamId else { throw UserError.userAccountNotFound }
                // SendToServer
                
                let _ = Document(teamId: teamId, name: "", info: "", url: "", roleString: "", createdAt: Date(), updatedAt: Date())
                
                try await Task.sleep(for: .seconds(2))
                
                self.toggleSheet()
                self.resetImage()
            } catch {
                print(error)
            }
        }
    }
}

extension UIImage {
    func scaleToWidth(_ width: CGFloat) -> UIImage {
        let scaleFactor = width / size.width
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: width, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func scaleToHeight(_ height: CGFloat) -> UIImage {
        let scaleFactor = height / size.height
        let newWidth = size.width * scaleFactor
        let newSize = CGSize(width: newWidth, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
