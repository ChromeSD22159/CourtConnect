//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @State var networkMonitorViewModel: NetworkMonitorViewModel = NetworkMonitorViewModel.shared
    @State var userAccountViewModel: UserAccountViewModel
    @State var syncServiceViewModel: SyncServiceViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
        self.userAccountViewModel = UserAccountViewModel(repository: userViewModel.repository, userId: userViewModel.user?.id)
        self.syncServiceViewModel = SyncServiceViewModel(repository: userViewModel.repository)
    }
    
    var body: some View {
        MessagePopover {
            TabView {
                Tab("Home", systemImage: "house.fill") {
                    DashboardView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                }
                
                if self.userViewModel.currentAccount?.roleEnum == .player {
                    Tab("Player", systemImage: "basketball.fill") {
                        DashboardView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                    }
                } else if self.userViewModel.currentAccount?.roleEnum == .trainer {
                    Tab("Trainer", systemImage: "basketball.fill") {
                        DashboardView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                    }
                }
                
                Tab("Termine", systemImage: "gear") {
                    EmptyView()
                }
                
                Tab("Settings", systemImage: "gear") {
                    SettingsView(userViewModel: userViewModel, networkMonitorViewModel: networkMonitorViewModel)
                        .environment(userAccountViewModel)
                }
            }
            .accentColor(Theme.lightOrange)
        }
        .sheet(isPresented: $userViewModel.showOnBoarding, content: {
            UserProfileEditView(userViewModel: userViewModel, isSheet: true)
        })
        .onChange(of: userViewModel.user, {
            Task {
                if let userId = userViewModel.userProfile?.userId {
                    do {
                        try await syncServiceViewModel.syncAllTables(userId: userId)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        })
        .onAppear {
            userAccountViewModel.importAccountsAfterLastSyncFromBackend()
        }
        .task {
            userViewModel.setUserOnline() 
            userViewModel.getCurrentAccount() 
            
            if await !NotificationService.getAuthStatus() {
                await NotificationService.request()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            userViewModel.changeOnlineStatus(phase: newPhase)
        }
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: Repository(type: .preview))
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: Repository(type: .preview), userId: nil)
    MainNavigationView(userViewModel: userViewModel)
}
