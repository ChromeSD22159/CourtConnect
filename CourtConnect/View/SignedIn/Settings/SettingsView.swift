//
//  SettingsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI
import WishKit
 
struct SettingsView: View {
    @Environment(\.networkMonitor) var networkMonitor
    @State var viewModel = SettingViewModel()
    
    let onSignOut: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 16) {
            Section {
                // MARK: - Edit Profile
                NavigationLink {
                    UserProfileEditView(isSheet: false)
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
                        OnlineUserList(viewModel: viewModel)
                    } label: {
                        IconRow(systemName: "person.2.fill", text: "Total Online Users: \(viewModel.onlineUserCount)")
                    }
                     
                    if let date = viewModel.userProfile?.lastOnline {
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
                    ConfirmButtonLabel(
                        confirmButtonDialog: ConfirmButtonDialog(
                            systemImage: "trash",
                            buttonText: "Delete CourtConnect Account",
                            question: "Want delete the CourtConnect Account",
                            message: "Are you sure you want to delete your CourtConnect Account? This action cannot be undone.",
                            action: "Delete",
                            cancel: "Cancel"
                        ),
                        color: .red
                    ) {
                        viewModel.deleteUser()
                    }
                }
            } header: {
                HStack {
                    UpperCasedheadline(text: "Account")
                    Spacer()
                }
            }
            
            Section {
                RowLabelButton(text: "Signout", systemImage: "iphone.and.arrow.forward", material: .ultraThinMaterial) {
                    viewModel.signOut()
                    onSignOut()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 120)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.getUser()
            viewModel.getUserAccount()
            viewModel.getUserProfile()
            viewModel.getAllOnlineUser()
            viewModel.startListeners()
        }
    }
}

fileprivate struct OnlineUserList: View {
    var viewModel: SettingViewModel
    @Environment(\.networkMonitor) var networkMonitor
    
    var body: some View {
        List {
            Section {
                Text("Total Online: \(viewModel.onlineUserCount)")
            }
            Section {
                if networkMonitor.isConnected == false {
                    HStack {
                        Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.exclamationmark")
                    }
                } else if viewModel.onlineUser.isEmpty {
                    Text("Nobody is online!")
                } else {
                    ForEach(viewModel.onlineUser, id: \.id) { onlineUser in
                        HStack {
                            
                            if let myUser: UserProfile = viewModel.userProfile {
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
                Link(destination: URL(string: url)!) { 
                    Label(text, systemImage: systemName)
                }
            } else {
                Label(text, systemImage: systemName)
            }
             
            Spacer()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .foregroundStyle(Theme.text)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    IconRow(systemName: "figure", text: "Instagram of the developer", url: "https://www.instagram.com/frederik.code/")
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingViewModel(), onSignOut: {})
    }
    .previewEnvirments()
    .navigationStackTint()
}

#Preview {
    WishKit.FeedbackListView().withNavigation()
} 
