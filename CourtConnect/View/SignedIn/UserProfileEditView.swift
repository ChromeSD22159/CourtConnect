//
//  UserProfileEditView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import SwiftUI

struct UserProfileEditView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: Field?
    let isSheet: Bool
    
    init(userViewModel: SharedUserViewModel, isSheet: Bool) {
        self.userViewModel = userViewModel
        self.isSheet = isSheet
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
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
                        if (userViewModel.user != nil) {
                            userViewModel.saveUserProfile()
                            dismiss()
                        }
                    }
                    .buttonStyle(RoundedFilledButtonStlye())

                }
            }
            
            Spacer()
             
            VStack(spacing: 10) {
                if let createdAt = userViewModel.userProfile?.createdAt {
                    Text("createdAt: \(createdAt.formatted(date: .long, time: .shortened))").font(.caption)
                }
                
                if let updatedAt = userViewModel.userProfile?.updatedAt {
                    Text("updatedAt: \(updatedAt.formatted(date: .long, time: .shortened))").font(.caption)
                }
                
                if let lastOnline = userViewModel.userProfile?.lastOnline {
                    Text("lastOnline: \(lastOnline.formatted(date: .long, time: .shortened))").font(.caption)
                }
                
                Button("Delete User Account") {
                    userViewModel.showDeleteConfirmMenu.toggle()
                }
                .buttonStyle(RoundedFilledButtonStlye())
                .confirmationDialog("Delete your Account", isPresented: $userViewModel.showDeleteConfirmMenu) {
                    Button("Delete", role: .destructive) {  userViewModel.deleteUser() }
                    Button("Cancel", role: .cancel) { userViewModel.showDeleteConfirmMenu.toggle() }
                } message: {
                    Text("Delete your Account")
                }
            }
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
