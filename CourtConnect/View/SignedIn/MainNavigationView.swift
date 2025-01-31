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
    
    var body: some View {
        MessagePopover {
            NavigationStack {
                NavigationTabBar(navViewModel: navViewModel) {
                    switch navViewModel.current {
                    case .home: DashboardView(userViewModel: userViewModel)
                    case .team: TeamView(userViewModel: userViewModel)
                    case .player: EmptyView()
                    case .settings: SettingsView(userViewModel: userViewModel)
                    }
                }
            }.navigationStackTint()
        }
        .sheet(isPresented: $userViewModel.showUserEditSheet, content: {
            UserProfileEditView(userViewModel: userViewModel, isSheet: true)
        })
        .onAppear {
            userViewModel.importAccountsAfterLastSyncFromBackend()
        }
        .task {
            userViewModel.setUserOnline() 
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
    MainNavigationView(userViewModel: userViewModel)
        .previewEnvirments()
}
