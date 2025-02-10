//
//  UserProfileEditView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import SwiftUI
import PhotosUI

@Observable @MainActor class UserProfileEditViewModel: ImagePickerProtocol {
    let repository: BaseRepository
    var item: PhotosPickerItem?
    var image: Image?
    var uiImage: UIImage?
    var fileName: String = ""
    
    @MainActor init() {
        self.repository = Repository.shared
    }
    
    @MainActor func uploadImage(userProfile: UserProfile) {
        guard let image = uiImage else { return }
        Task {
            do {
                let userprifile = try await SupabaseService.uploadUserImageToSupabaseAndCache(image: image, userProfile: userProfile)
                try repository.userRepository.insertOrUpdate(profile: userprifile.toModel(), table: .userProfile, userId: userprifile.userId)
            } catch {
                print(error)
            }
        }
    }
}

struct UserProfileEditView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @State var userProfileEditViewModel = UserProfileEditViewModel()
    
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: Field?
    let isSheet: Bool
    
    init(userViewModel: SharedUserViewModel, isSheet: Bool) {
        self.userViewModel = userViewModel
        self.isSheet = isSheet
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
            HStack(spacing: 20) {
                if let image = userProfileEditViewModel.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                               .stroke(Theme.topTrailingbottomLeadingGradient, lineWidth: 5)
                        )
                } else {
                    Image(.basketballPlayerProfile)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                               .stroke(Theme.topTrailingbottomLeadingGradient, lineWidth: 5)
                        )
                }
                
                PhotosPicker(selection: $userProfileEditViewModel.item) {
                    Label(userProfileEditViewModel.item == nil ? "Choose Document" : "Change Document", systemImage: "text.page.badge.magnifyingglass")
                        .padding()
                        .foregroundStyle(.white)
                        .background(Theme.darkOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .onChange(of: userProfileEditViewModel.item) {
                    userProfileEditViewModel.setImage()
                }
            }
             
            TextField("Firstname", text: $userViewModel.editProfile.firstName)
                .focused($focus, equals: Field.firstName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Lastname", text: $userViewModel.editProfile.lastName)
                .focused($focus, equals: Field.lastName)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("Birthday", selection: userViewModel.birthBinding, displayedComponents: .date)
            .datePickerStyle(.compact)
            
            if !isSheet {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(RoundedFilledButtonStlye())
                    
                    Button("Save Profile", role: .destructive) {
                        if (userViewModel.user != nil), let userProfile = userViewModel.userProfile {
                            userViewModel.saveUserProfile()
                            userProfileEditViewModel.uploadImage(userProfile: userProfile)
                            dismiss()
                        }
                    }
                    .buttonStyle(RoundedFilledButtonStlye())

                }
            }
            
            Spacer() 
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .toolbar {
            if isSheet {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Profile", role: .destructive) {
                        if (userViewModel.user != nil) {
                            userViewModel.saveUserProfile()
                            dismiss()
                        }
                    }
                    .tint(.primary)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Edit User")
        .padding()
        .onAppear {
            if let profile = userViewModel.userProfile {
                userViewModel.setEditUserProfile(userProfile: profile)
            } else {
                userViewModel.resetEditUserProfile()
            }
        }
    }
    
    enum Field {
        case firstName, lastName
    }
} 

#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    UserProfileEditView(userViewModel: userViewModel, isSheet: true)
        .previewEnvirments()
}
