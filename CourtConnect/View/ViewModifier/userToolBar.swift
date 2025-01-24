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
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink("DEBUG") {
                        DebugView(userAccountViewModel: userAccountViewModel, userViewModel: userViewModel)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "person.fill")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                        
                        MenuButton(icon: "person.3.fill") {
                            Text("Create New Account or Switch to Existing Account")
                            
                            ForEach(userAccountViewModel.accounts) { account in
                                Button {
                                    userViewModel.setCurrentAccount(newAccount: account) 
                                } label: {
                                    HStack {
                                        if userViewModel.currentAccount?.id == account.id {
                                            Image(systemName: "xmark")
                                        }
                                        
                                        Text("\(account.role) \(account.isDeleted)")
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
                    .foregroundStyle(.red)
                }
            } 
    }
}

struct DebugView: View {
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    var body: some View {
        Form {
            Button("DEBUG DELETE") {
                userAccountViewModel.debugdelete()
                userViewModel.setCurrentAccount(newAccount: nil)
            }.padding(.top, 50)
        }
    }
}

extension View {
    /// REQUIRE
    func userToolBar(userViewModel: SharedUserViewModel, userAccountViewModel: UserAccountViewModel) -> some View {
        modifier(UserToolBar(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel))
    }
}

#Preview {
    NavigationStack {
        ZStack {
            
        }.userToolBar(
            userViewModel: SharedUserViewModel(repository: Repository(type: .preview)),
            userAccountViewModel: UserAccountViewModel(repository: Repository(type: .preview), userId: nil)
        )
    }
}
