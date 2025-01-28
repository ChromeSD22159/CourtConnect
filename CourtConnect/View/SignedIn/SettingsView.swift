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
    
    var body: some View {
        List {
            Section {
                // MARK: - Edit Profile
                NavigationLink {
                    UserProfileEditView(userViewModel: userViewModel, isSheet: false)
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
                        Text("Last online:")
                        Spacer()
                        Text(date.formattedDate() + " " + date.formattedTime() + " Uhr")
                    }
                } else {
                    Text("Last online: -")
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
                Button("Logout") {
                    userViewModel.signOut()
                }
                .foregroundStyle(.white)
                .listRowBackground(Theme.darkOrange)
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
                    Text("Nobody is online!")
                } else {
                    ForEach(userViewModel.onlineUser, id: \.id) { onlineUser in
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
