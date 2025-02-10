//
//  UserProfileEditViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import PhotosUI
import SwiftUI
import Auth

@Observable @MainActor
class UserProfileEditViewModel: ImagePickerProtocol, AuthProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
     
    var item: PhotosPickerItem?
    var image: Image?
    var uiImage: UIImage?
    var fileName: String = ""
    
    var editProfile: UserProfile = UserProfile(userId: UUID(), firstName: "", lastName: "", birthday: "", createdAt: Date(), updatedAt: Date())
    var birthBinding: Binding<Date> {
        Binding {
            if let date = DateUtil.stringToDateDDMMYYYY(string: self.editProfile.birthday) {
                return date
            } else {
                return Date()
            }
        } set: { updatedDate in
            self.editProfile.birthday = DateUtil.dateDDMMYYYYToString(date: updatedDate)
        }
    }
    
    func uploadImage(userProfile: UserProfile) async throws -> String? {
        guard let image = uiImage else { return nil }
        let imageString: String = try await SupabaseService.uploadUserImageToSupabaseAndCache(image: image, userProfile: userProfile)
        
        userProfile.imageURL = imageString
        try repository.userRepository.insertOrUpdate(profile: userProfile, table: .userProfile, userId: userProfile.userId)
        return imageString
    }
    
    func resetEditUserProfile() {
        guard let user = user else { return }
        self.editProfile = UserProfile(userId: user.id, firstName: "", lastName: "", birthday: "", createdAt: Date(), updatedAt: Date())
    }
    
    func setEditUserProfile(userProfile: UserProfile) {
        self.editProfile = userProfile
    }
    
    func saveUserProfile() {
        guard
            let user = self.user,
            !editProfile.firstName.isEmpty,
            !editProfile.lastName.isEmpty
        else {
            return
        }
        
        editProfile.userId = user.id
        editProfile.updatedAt = Date()
        
        Task {
            do {
                try await self.repository.userRepository.sendUserProfileToBackend(profile: editProfile)
            } catch {
                print("UserVM: " + error.localizedDescription)
            }
        }
    }
}
