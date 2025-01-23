//
//  CreateUserAccountView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import SwiftUI

struct CreateUserAccountView: View {
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
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
                        userAccountViewModel.insertAccount { result in
                            switch result {
                            case .success(let account):
                                userViewModel.currentAccount = account 
                            case .failure(_): break
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
        .presentationDetents([.height(300)])
    }
}
 
#Preview {
    ZStack { 
    }
    .sheet(isPresented: .constant(true)) {
        CreateUserAccountView(
            userAccountViewModel: UserAccountViewModel(repository: Repository(type: .preview), userId: "nil"),
            userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
            .shadow(radius: 5)
    }
}
