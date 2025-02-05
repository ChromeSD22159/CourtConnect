//
//  SettingsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import Foundation
import SwiftUI
import WishKit

struct SettingsView: View {
    @Environment(\.networkMonitor) var networkMonitor
    @ObservedObject var userViewModel: SharedUserViewModel
    
    var body: some View {
        List {
            Section {
                // MARK: - Edit Profile
                NavigationLink {
                    UserProfileEditView(userViewModel: userViewModel, isSheet: false)
                        .background(Theme.background)
                } label: {
                    Text("Your Profile")
                }

            } header: {
                Text("Profile")
            }
            
            Section {
                NavigationLink("DEBUG Options") {
                    DebugView(userViewModel: userViewModel)
                }
            } header: {
                Text("Development")
            }
            
            Section {
                // MARK: - Total Online Users
                NavigationLink {
                    OnlineUserList(userViewModel: userViewModel)
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
                NavigationLink {
                    WishKit.FeedbackListView().withNavigation()
                } label: {
                    Text("Features")
                }

            } header: {
                Text("The Developer")
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
    @ObservedObject var userViewModel: SharedUserViewModel
    var body: some View {
        Form {
            Button("DEBUG DELETE All UserAccounts") { 
                userViewModel.setCurrentAccount(newAccount: nil)
            }
        }
        .listBackground()
    }
}

fileprivate struct OnlineUserList: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @Environment(\.networkMonitor) var networkMonitor
    
    var body: some View {
        List {
            Section {
                Text("Total Online: \(userViewModel.onlineUserCount)")
            }
            Section {
                if networkMonitor.isConnected == false {
                    HStack {
                        Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.exclamationmark")
                    }
                } else if userViewModel.onlineUser.isEmpty {
                    Text("Nobody is online!")
                } else {
                    ForEach(userViewModel.onlineUser, id: \.id) { onlineUser in
                        HStack {
                            
                            if let myUser: UserProfile = userViewModel.userProfile {
                                NavigationLink {
                                    ChatView(myUser: myUser, recipientUser: onlineUser.toUserProfile())
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
        .listBackground()
    }
}

#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared) 
    NavigationStack {
        SettingsView(userViewModel: userViewModel)
    }
    .previewEnvirments()
    .navigationStackTint()
}

#Preview {
    WishKit.FeedbackListView().withNavigation()
} 
