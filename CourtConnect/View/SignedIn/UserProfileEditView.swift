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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                TextField("Firstname", text: $userViewModel.editProfile.firstName)
                    .focused($focus, equals: Field.firstName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("LastName", text: $userViewModel.editProfile.lastName)
                    .focused($focus, equals: Field.lastName)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker("Birthday", selection: userViewModel.birthBinding, displayedComponents: .date)
                .datePickerStyle(.compact)
                
                HStack {
                    Text("Account Type:")
                    Spacer()
                    Picker("Account Type:", selection: $userViewModel.editProfile.roleString, content: {
                        ForEach(UserRole.registerRoles, id: \.rawValue) { role in
                            Text(role.rawValue).tag(role.rawValue)
                        }
                    })
                    .pickerStyle(.menu)
                    .tint(.primary)
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
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .toolbar {
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
    UserProfileEditView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
}
