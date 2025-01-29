//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkMonitor) var networkMonitor
    @Environment(SyncServiceViewModel.self) private var syncServiceViewModel
    @State var navViewModel = NavigationViewModel.shared
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var userAccountViewModel: UserAccountViewModel 
    
    var body: some View {
        MessagePopover {
            NavigationStack {
                NavigationTabBar(navViewModel: navViewModel) {
                    switch navViewModel.current {
                    case .home: DashboardView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
                    case .team: TeamView()
                    case .player: EmptyView()
                    case .settings: SettingsView(userViewModel: userViewModel).environment(userAccountViewModel)
                    }
                }
            }.navigationStackTint()
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
            
            if newPhase == .background {
                Task {
                    print("disappear")
                    guard let userId = userViewModel.user?.id else { return }
                    try await syncServiceViewModel.sendAllData(userId: userId)
                }
            }
        }
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    @Previewable @State var userAccountViewModel = UserAccountViewModel(repository: RepositoryPreview.shared, userId: nil)
    MainNavigationView(userViewModel: userViewModel, userAccountViewModel: userAccountViewModel)
        .previewEnvirments()
}
