//
//  CreateUserAccountView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import SwiftUI 

struct CreateUserAccountView: View {
    @State var userAccountViewModel: CreateUserAccountViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
        self.userAccountViewModel = CreateUserAccountViewModel(repository: userViewModel.repository)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Picker("Kind", selection: $userAccountViewModel.role) {
                    ForEach(UserRole.registerRoles) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
                .listRowSeparatorTint(.orange)

                if userAccountViewModel.role == .player {
                    Picker("Position", selection: $userAccountViewModel.position) {
                        ForEach(BasketballPosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create User Account")
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            do {
                                let newAccount = try userAccountViewModel.insertAccount() 
                                if let newAccount = newAccount {
                                    try await userAccountViewModel.sendToServer(account: newAccount)
                                }
                                userViewModel.setCurrentAccount(newAccount: newAccount)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: {
                        
                    })
                }
            }
        }
        .navigationStackTint()
        .presentationDetents([.height(300)])
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    ZStack {
    }
    .sheet(isPresented: .constant(true)) {
        CreateUserAccountView(
            userViewModel: userViewModel
        )
        .shadow(radius: 5)
        .previewEnvirments()
    }
}
