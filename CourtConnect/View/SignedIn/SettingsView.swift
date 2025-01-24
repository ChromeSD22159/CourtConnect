//
//  SettingsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import Foundation 
import SwiftUI

struct SettingsView: View {
    @Environment(UserAccountViewModel.self) var userAccountViewModel: UserAccountViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var networkMonitorViewModel: NetworkMonitorViewModel
    
    @AppStorage("isBackendLocal") var isBackendLocal = true
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // MARK: - Edit Profile
                    NavigationLink {
                        UserProfileEditView(userViewModel: userViewModel)
                    } label: {
                        Text("Your Profile")
                    }

                } header: {
                    Text("Profile")
                }
                
                Section {
                    NavigationLink("DEBUG Options") {
                        DebugView(userAccountViewModel: userAccountViewModel, userViewModel: userViewModel)
                    }
                    
                    Toggle("isBackendLocal", isOn: $isBackendLocal)
                        .tint(Theme.lightOrange)
                } header: {
                    Text("Development")
                }
                
                Section {
                    
                    // MARK: - Total Online Users
                    NavigationLink {
                        OnlineUserList(userViewModel: userViewModel, networkMonitorViewModel: networkMonitorViewModel)
                    } label: {
                        Text("Total Online Users: \(userViewModel.onlineUserCount)")
                    }
                    
                    // MARK: - LastOnline
                    if let date = userViewModel.userProfile?.lastOnline {
                        HStack {
                            Text("Zuletzt Online:")
                            Spacer()
                            Text(date.formattedDate() + " " + date.formattedTime() + " Uhr")
                        }
                    } else {
                        Text("Zuletzt Online: -")
                    }
                    
                    // MARK: - Version
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version: \(appVersion)")
                    } else {
                        Text("Version: -")
                    }
                } header: {
                    Text("App Status")
                }
                
                Section {
                    Text("Delete User Account")
                        .onTapGesture {
                            userViewModel.showDeleteConfirmMenu.toggle()
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(Theme.lightOrange)
                        .confirmationDialog("Delete your Account", isPresented: $userViewModel.showDeleteConfirmMenu) {
                            Button("Delete", role: .destructive) {  userViewModel.deleteUserAccount() }
                            Button("Cancel", role: .cancel) { userViewModel.showDeleteConfirmMenu.toggle() }
                        } message: {
                            Text("Delete your Account")
                        }
                }
                
                Section {
                    Text("Logout")
                        .onTapGesture {
                            userViewModel.signOut()
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(Theme.darkOrange)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            userViewModel.getAllOnlineUser()
            userViewModel.startListeners()
        }
    }
}
 
fileprivate struct DebugView: View {
    @ObservedObject var userAccountViewModel: UserAccountViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    var body: some View {
        Form {
            Button("DEBUG DELETE All UserAccounts") {
                userAccountViewModel.debugdelete()
                userViewModel.setCurrentAccount(newAccount: nil)
            }
        }
    }
}

fileprivate struct OnlineUserList: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var networkMonitorViewModel: NetworkMonitorViewModel
    var body: some View {
        List {
            Section {
                Text("Total Online: \(userViewModel.onlineUserCount)")
            }
            Section {
                if networkMonitorViewModel.isConnected == false {
                    HStack {
                        Image(systemName: networkMonitorViewModel.isConnected ? "wifi" : "wifi.exclamationmark")
                    }
                } else if userViewModel.onlineUser.isEmpty {
                    Text("Niemand ist Online!")
                } else {
                    ForEach(userViewModel.onlineUser) { onlineUser in
                        HStack {
                            if let myUser: UserProfile = userViewModel.userProfile {
                                NavigationLink { 
                                    ChatView(repository: userViewModel.repository, myUser: myUser, recipientUser: onlineUser.toUserProfile())
                                } label: {
                                    Text(onlineUser.firstName + " " + onlineUser.lastName)
                                }
                            } 
                            
                            Spacer()
                        }
                    }
                }
            }
        } 
    }
}

#Preview {
    SettingsView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)), networkMonitorViewModel: NetworkMonitorViewModel())
        .environment(UserAccountViewModel(repository: Repository(type: .preview), userId: nil))
}
