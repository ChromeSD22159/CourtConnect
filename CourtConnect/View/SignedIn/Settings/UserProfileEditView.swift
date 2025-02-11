//
//  UserProfileEditView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import SwiftUI
import PhotosUI

struct UserProfileEditView: View {
    @State var userProfileEditViewModel = UserProfileEditViewModel()
    
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: Field?
    let isSheet: Bool 
    
    var body: some View {
        VStack(spacing: 25) {
            
            HStack(spacing: 20) {
                if let image = userProfileEditViewModel.image { // User Selected an ProfileImage
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
                    if let imageURL = userProfileEditViewModel.userProfile?.imageURL { // User has ProfileImage
                        AsyncCachedImage(url: URL(string: imageURL)!) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                       .stroke(Theme.topTrailingbottomLeadingGradient, lineWidth: 5)
                                )
                        } placeholder: {
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
                    } else { // User has no ProfileImage
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
              
            TextField("Firstname", text: $userProfileEditViewModel.editProfile.firstName)
                .focused($focus, equals: Field.firstName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Lastname", text: $userProfileEditViewModel.editProfile.lastName)
                .focused($focus, equals: Field.lastName)
                .textFieldStyle(.roundedBorder)
            
            DatePicker("Birthday", selection: userProfileEditViewModel.birthBinding, displayedComponents: .date)
            .datePickerStyle(.compact)
            
            if !isSheet {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(RoundedFilledButtonStlye())
                    
                    Button("Save Profile", role: .destructive) {
                        if (userProfileEditViewModel.user != nil), let userProfile = userProfileEditViewModel.userProfile {
                            Task {
                                do {
                                    userProfileEditViewModel.userProfile?.imageURL = try await userProfileEditViewModel.uploadImage(userProfile: userProfile)
                                    userProfileEditViewModel.saveUserProfile()
                                    dismiss()
                                } catch {
                                    print(error)
                                }
                            }
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
                        if (userProfileEditViewModel.user != nil) {
                            userProfileEditViewModel.saveUserProfile()
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
            userProfileEditViewModel.getUser()
            userProfileEditViewModel.getUserProfile()
            userProfileEditViewModel.getUserAccount()
            
            if let profile = userProfileEditViewModel.userProfile {
                userProfileEditViewModel.setEditUserProfile(userProfile: profile)
            } else {
                userProfileEditViewModel.resetEditUserProfile()
            }
        }
    }
    
    enum Field {
        case firstName, lastName
    }
} 

#Preview { 
    UserProfileEditView(isSheet: false)
        .previewEnvirments()
}
