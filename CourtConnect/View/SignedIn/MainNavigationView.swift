//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    @State var navViewModel = NavigationViewModel.shared
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
            NavigationTabBar(navViewModel: navViewModel) {
                switch navViewModel.current {
                case .home: DashboardView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel, syncServiceViewmodel: syncServiceViewModel)
                case .settings: SettingsView(userViewModel: userViewModel, networkMonitorViewModel: networkMonitorViewModel)
                        .environment(userAccountViewModel)
                }
            } 
        }
        .sheet(isPresented: $userViewModel.showUserEditSheet, content: {
            UserProfileEditView(userViewModel: userViewModel, isSheet: true)
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
