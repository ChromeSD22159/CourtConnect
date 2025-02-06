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
        LazyVStack(spacing: 16) {
            Section {
                // MARK: - Edit Profile
                NavigationLink {
                    UserProfileEditView(userViewModel: userViewModel, isSheet: false)
                        .background(Theme.background)
                } label: {
                    IconRow(systemName: "person.fill", text: "Your Profile")
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "Profile")
                    Spacer()
                }
            }
            
            Section {
                VStack(spacing: 6) {
                    NavigationLink {
                        OnlineUserList(userViewModel: userViewModel)
                    } label: {
                        IconRow(systemName: "person.2.fill", text: "Total Online Users: \(userViewModel.onlineUserCount)")
                    }
                     
                    if let date = userViewModel.userProfile?.lastOnline {
                        IconRow(systemName: "person.badge.clock.fill", text: "Last online: " + date.formattedDate() + " " + date.formattedTime() + " Uhr")
                    } else {
                        IconRow(systemName: "person.badge.clock.fill", text: "Last online: -")
                    }
                    
                    // MARK: - Version
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        IconRow(systemName: "info.circle.fill", text: "Version: \(appVersion)")
                    } else {
                        IconRow(systemName: "info.circle.fill", text: "Version: -")
                    }
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "App Status")
                    Spacer()
                }
            }
            
            Section {
                VStack(spacing: 6) {
                    NavigationLink {
                        WishKit.FeedbackListView().withNavigation()
                    } label: {
                        IconRow(systemName: "list.bullet.clipboard.fill", text: "Features")
                    }

                    IconRow(systemName: "globe", text: "Instagram of the developer", url: "https://www.instagram.com/frederik.code/")
                    
                    IconRow(systemName: "globe", text: "Webseite des Entwicklers", url: "https://www.frederikkohler.de")
                    
                    IconRow(systemName: "square.grid.2x2.fill", text: "Apps des Entwicklers", url: "https://apps.apple.com/at/developer/frederik-kohler/id1692240999")
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "The Developer")
                    Spacer()
                }
            }
            
            Section {
                VStack(spacing: 6) {
                    IconRow(systemName: "trash", text: "Delete UserAccount")
                    
                    IconRow(systemName: "trash", text: "Delete CourtConnect Account")
                    
                    IconRow(systemName: "trash", text: "Delete Team")
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "Account")
                    Spacer()
                }
            }
            
            Section {
                IconRow(systemName: "iphone.and.arrow.forward", text: "Signout")
                    .onTapGesture {
                        userViewModel.signOut()
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 120)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            userViewModel.getAllOnlineUser()
            userViewModel.startListeners()
        }
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

fileprivate struct IconRow: View {
    let systemName: String
    let text: String
    let url: String?
    
    init(systemName: String, text: String) {
        self.systemName = systemName
        self.text = text
        self.url = nil
    }
    
    init(systemName: String, text: String, url: String) {
        self.systemName = systemName
        self.text = text
        self.url = url
    }
    
    var body: some View {
        HStack {
            if let url = url {
                Link(destination: URL(string: url)!) { // Link statt Label und onOpenURL
                    Label(text, systemImage: systemName)
                }
            } else {
                Label(text, systemImage: systemName)
            }
             
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Material.ultraThinMaterial)
        .foregroundStyle(Theme.text)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    IconRow(systemName: "figure", text: "Instagram of the developer", url: "https://www.instagram.com/frederik.code/")
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
