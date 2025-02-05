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
    @State var navViewModel = NavigationViewModel.shared
    @ObservedObject var userViewModel: SharedUserViewModel
    @Environment(SyncServiceViewModel.self) var syncServiceViewModel
    var body: some View {
        MessagePopover {
            NavigationStack {
                NavigationTabBar(navViewModel: navViewModel) {
                    switch navViewModel.current {
                    case .home: DashboardView(userViewModel: userViewModel)
                    case .team: TeamView(userViewModel: userViewModel)
                    case .player: PlayerStatistic(userViewModel: userViewModel)
                    case .settings: SettingsView(userViewModel: userViewModel)
                    }
                }
            }.navigationStackTint()
        }
        .sheet(isPresented: $userViewModel.isEditSheet, content: {
            UserProfileEditView(userViewModel: userViewModel, isSheet: true)
        })
        .onAppear {
            userViewModel.importAccountsAfterLastSyncFromBackend()
        }
        .task {
            userViewModel.setUserOnline()
            
            if await !NotificationService.getAuthStatus() {
                await NotificationService.request()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            userViewModel.changeOnlineStatus(phase: newPhase) 
        }
        .fullScreenCover(
            isPresented: $userViewModel.isOnboardingSheet,
            onDismiss: {
                userViewModel.onDismissOnBoarding(syncServiceViewModel: syncServiceViewModel)
            },
            content: {
                if let userProfile = userViewModel.userProfile {
                    OnBoardingView(userProfile: userProfile)
                }
            }
        )
    }
}
 
#Preview {
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    MainNavigationView(userViewModel: userViewModel)
        .previewEnvirments()
}
