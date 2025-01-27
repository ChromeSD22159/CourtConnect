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
    
    @State var networkMonitorViewModel: NetworkMonitorViewModel = NetworkMonitorViewModel()
    @State var userAccountViewModel: UserAccountViewModel
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
        self.userAccountViewModel = UserAccountViewModel(repository: userViewModel.repository, userId: userViewModel.user?.id)
    }
    
    var body: some View {
        MessagePopover {
            TabView {
                Tab("Home", systemImage: "house.fill") {
                    DashboardView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel, networkMonitorViewModel: networkMonitorViewModel)
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
        .onAppear {
            userAccountViewModel.importAccountsAfterLastSyncFromBackend()
        } 
        .task {
            userViewModel.setUserOnline() 
            
            userViewModel.setCurrentAccount(newAccount: userAccountViewModel.getCurrentAccount())
            
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
