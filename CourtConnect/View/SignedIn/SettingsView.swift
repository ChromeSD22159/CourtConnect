//
//  SettingsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import Foundation
import Supabase
import SwiftUI

struct SettingsView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    var body: some View {
        NavigationStack {
            List {
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
                    Text("Logout")
                        .onTapGesture {
                            userViewModel.signOut()
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(Color.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Image(systemName: "person.fill")
                            .padding(10)
                            .onTapGesture {
                                userViewModel.openEditProfileSheet()
                            }
                    }
                }
            }
        }
        
    }
}
 
fileprivate struct OnlineUserList: View {
    @ObservedObject var userViewModel: SharedUserViewModel
     
    var body: some View {
        List {
            Section {
                Text("Total Online: \(userViewModel.onlineUserCount)")
            }
            Section {
                if userViewModel.onlineUser.isEmpty {
                    Text("Niemand ist Online!")
                } else {
                    ForEach(userViewModel.onlineUser) { onlineUser in
                        HStack() {
                            if let myUser: UserProfile = userViewModel.userProfile  {
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
        .onAppear {
            userViewModel.getAllOnlineUser()
        }
    }
}

#Preview {
    SettingsView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)))
}
