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
    
    var body: some View {
        VStack {
            Text(userViewModel.user?.id.uuidString ?? "")
            Text(userViewModel.editProfile.userId)
            
            TextField("Firstname", text: $userViewModel.editProfile.firstName)
            
            TextField("LastName", text: $userViewModel.editProfile.lastName)

            DatePicker("Birthday", selection: userViewModel.birthBinding, displayedComponents: .date)
            .datePickerStyle(.compact)
            
            Picker("", selection: $userViewModel.editProfile.roleString, content: {
                ForEach(UserRole.allCases, id: \.rawValue) { role in
                    Text(role.rawValue).tag(role.rawValue)
                }
            })
            
            Button("Save Profile") {
                if (userViewModel.user != nil) {
                    userViewModel.saveUserProfile()
                    dismiss()
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
            }
        }
        .padding()
        .onAppear {
            if let profile = userViewModel.userProfile {
                userViewModel.setEditUserProfile(userProfile: profile)
            } else {
                userViewModel.resetEditUserProfile()
            }
        }
    }
}

#Preview {
    UserProfileEditView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
}
