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
            Text(userViewModel.editProfile.id.uuidString.lowercased())
            
            TextField("Firstname", text: $userViewModel.editProfile.firstName)
            
            TextField("LastName", text: $userViewModel.editProfile.lastName)
            
            Text(userViewModel.editProfile.birthday.formatted(.dateTime))
            
            DatePicker("", selection: $userViewModel.editProfile.birthday, displayedComponents: .date)
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
