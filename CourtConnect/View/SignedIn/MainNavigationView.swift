//
//  ContentView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import SwiftUI

struct MainNavigationView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var navViewModel = NavigationViewModel.shared
    
    var authViewModel: AuthViewModel
    
    let onSignOut: () -> Void
    
    var body: some View {
        MessagePopover {
            NavigationStack {
                NavigationTabBar(navViewModel: navViewModel) {
                    switch navViewModel.current {
                    case .home: DashboardView()
                    case .team: TeamView()
                    case .player: PlayerStatistic()
                    case .settings: SettingsView(onSignOut: onSignOut)
                    }
                }
            }.navigationStackTint()
        }
        .onAppear { 
            authViewModel.importAccountsAfterLastSyncFromBackend()
        }
        .task {
            authViewModel.setUserOnline()
            
            if await !NotificationService.getAuthStatus() {
                await NotificationService.request()
            }
            
            do {
                if let user = authViewModel.user {
                    try await authViewModel.syncAllTables(userId: user.id)
                }
            } catch {
                print(error)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { 
                authViewModel.setUserOnline()
            } else if newPhase == .background {
                authViewModel.setUserOffline()
            }
        }
    }
}
 
#Preview {
    MainNavigationView(authViewModel: AuthViewModel(), onSignOut: {})
        .previewEnvirments()
}
