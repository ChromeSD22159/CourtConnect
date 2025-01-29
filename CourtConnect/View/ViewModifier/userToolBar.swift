//
//  UserToolBar.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import SwiftUI

struct UserToolBar: ViewModifier {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $userAccountViewModel.isCreateRoleSheet, content: {
                CreateUserAccountView(userAccountViewModel: userAccountViewModel, userViewModel: userViewModel) 
            })
            .toolbar { 
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "person.fill")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                        
                        IconMenuButton(icon: "person.3.fill", description: "Create New Account or Switch to Existing Account") { 
                            ForEach(userAccountViewModel.accounts) { account in
                                Button {
                                    userViewModel.setCurrentAccount(newAccount: account)
                                } label: {
                                    HStack {
                                        if userViewModel.currentAccount?.id == account.id {
                                            Image(systemName: "xmark")
                                                .font(.callout)
                                        }
                                        
                                        Text("\(account.displayName)")
                                    }
                                }
                            }
                            
                            if !userAccountViewModel.hasBothRoles() {
                                Button {
                                    userAccountViewModel.isCreateRoleSheet.toggle()
                                } label: {
                                    Label("Create User Account", systemImage: "plus")
                                }
                                
                            }
                        } 
                    }
                    .foregroundStyle(Theme.lightOrange)
                }
            } 
    }
} 

extension View {
    func userToolBar(userViewModel: SharedUserViewModel, userAccountViewModel: UserAccountViewModel) -> some View {
        modifier(UserToolBar(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel))
    }
}

#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: RepositoryPreview.shared, userId: nil)
    NavigationStack {
        ZStack {
            
        }.userToolBar(
            userViewModel: userViewModel,
            userAccountViewModel: userAccountViewModel
        )
    }
    .previewEnvirments()
    .navigationStackTint()
}
