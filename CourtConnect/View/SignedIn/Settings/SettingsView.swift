//
//  SettingsViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.01.25.
//
import SwiftUI
import WishKit
import StoreKit

struct SettingsView: View {
    @Environment(\.networkMonitor) var networkMonitor
    @Environment(\.requestReview) var requestReview
    @State var viewModel = SettingViewModel()
    
    @Namespace var namespace
    
    let onSignOut: () -> Void
    
    var body: some View {
        LazyVStack(spacing: 16) {
            Section {
                // MARK: - Edit Profile
                NavigationLink {
                    UserProfileEditView(isSheet: false)
                        .background(Theme.backgroundGradient)
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
                    if networkMonitor.isConnected {
                        IconRow(systemName: "person.2.fill", text: .init("Total Online Users: \(viewModel.onlineUserCount)"))
                    } else {
                        InternetUnavailableView()
                    } 
                     
                    if let date = viewModel.userProfile?.lastOnline, let formattedDate = date.formattedDate().stringKey, let formattedTime = date.formattedTime().stringKey {
                        let localizedKey: LocalizedStringKey = "Last online: \(formattedDate) \(formattedTime) o'clock"
                        IconRow(systemName: "person.badge.clock.fill", text: localizedKey)
                    } else {
                        IconRow(systemName: "person.badge.clock.fill", text: .init("Last online: -"))
                    }
                    
                    // MARK: - Version
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        IconRow(systemName: "info.circle.fill", text: .init("Version: \(appVersion)"))
                    } else {
                        IconRow(systemName: "info.circle.fill", text: .init("Version: -"))
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
                    if let userProfile = viewModel.userProfile {
                        NavigationLink { 
                                OnBoardingSlider(userProfile: userProfile)
                                    .navigationTransition(.zoom(sourceID: "OnBoardingSlider", in: namespace))
                                    .navigationBarBackButtonHidden(true)
                            
                        } label: {
                            IconRow(systemName: "list.bullet.clipboard.fill", text: .init("Show Onboarding"))
                        }
                    }
                    
                    IconRow(systemName: "list.bullet.clipboard.fill", text: .init("Rate the App"))
                        .onTapGesture {
                            requestReview()
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
                        IconRow(systemName: "list.bullet.clipboard.fill", text: .init("Features"))
                    }

                    IconRow(systemName: "globe", text: .init("Instagram of the developer"), url: "https://www.instagram.com/frederik.code/")
                    
                    IconRow(systemName: "globe", text: .init("Website of the developer"), url: "https://www.frederikkohler.de")
                    
                    IconRow(systemName: "square.grid.2x2.fill", text: .init("The developer apps"), url: "https://apps.apple.com/at/developer/frederik-kohler/id1692240999")
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
                            question: "Want delete the CourtConnect Account?",
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
        .scrollContentBackground(.hidden)
        .navigationTitle(title: "Settings")
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
                if networkMonitor.isConnected {
                    Text("Total Online: \(viewModel.onlineUserCount)")
                } else {
                    InternetUnavailableView()
                }
            }
            .onAppear {
                print(networkMonitor.isConnected)
                print(NetworkMonitorViewModel.shared.isConnected)
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
    let text: LocalizedStringKey
    let url: String?
    
    init(systemName: String, text: LocalizedStringKey) {
        self.systemName = systemName
        self.text = text
        self.url = nil
    }
    
    init(systemName: String, text: LocalizedStringKey, url: String) {
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
